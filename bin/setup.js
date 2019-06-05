#!/usr/bin/env node

var opts = require("yargs");
var shell = require("shelljs");
var _ = require("lodash");
const fs = require("fs");

var argv = opts
  .usage("Usage: $0 --users='1..10' --project-names='one,two'")
  .option("kube-config-file", {
    alias: "k",
    description: "kubeconfig file location"
  })
  .option("admin-password", {
    alias: "a",
    description: "the default cluster admin password to set"
  })
  .option("create-users", { alias: "c", description: "Create Workshop Users" })
  .option("users", {
    alias: "u",
    description: "Number workshop users to create",
    default: "1..10"
  })
  .option("user-suffix", {
    alias: "s",
    description: "The suffix for the workshop users",
    default: "user"
  })
  .option("default-user-password", {
    alias: "p",
    description: "The default password for the workshop user",
    default: "openshift"
  })
  .option("project-names", {
    alias: "n",
    description: "The workshop projects that needs to be created",
    default: "knativetutorial"
  })
  .demandOption(
    "kube-config-file",
    'Please provide the "kube-config-file" for run this tool e.g. setup.js --kube-config-file <path to your kubeconfig file>'
  )
  .option("cleanup", {
    alias: "d",
    description: "Cleanup workshop setup delete projects and remove roles"
  })
  .boolean(["create-users", "cleanup"]).argv;

function range(val) {
  return val.split("..").map(Number);
}

//Set OpenShift Env
try {
  if (fs.existsSync(argv.k)) {
    //file exists
  }
} catch (err) {
  console.error(`KubeConfig file ${argv.k} does not exist`);
  shell.exit(1);
}

//Process and set the values in the environment

//Kubeconfig file location
process.env.KUBECONFIG = argv.k;

//The Workshop Projects that need to be created
process.env.PROJECTS = _.replace(argv.n, /,/g, " ");
var userRange = range(argv.u);
//the Workshop Users range like 1..50, 100..200 etc.,
process.env.USERS_FROM = userRange[0];
process.env.USERS_TO = userRange[1];

//The Workshop user suffix default is 'user'
process.env.USER_SUFFIX = argv.s;
//The default user password
process.env.USER_PASSWORD = argv.p;

//Login to OpenShift as system:admin
result = shell.exec(`${__dirname}/ocSysAdminLogin.sh`);
if (result.code !== 0) {
  shell.echo(result.stderr);
  shell.exit(1);
}

//Clear setup
if (argv.d) {
  result = shell.exec(`${__dirname}/cleanup.sh`);
  if (result.code !== 0) {
    shell.echo(result.stderr);
    shell.exit(1);
  }
  console.log("Cleaned up workshop setup");
  shell.exit(0);
}

console.log(`Projects to be created : ${process.env.PROJECTS}`);
console.log(
  `No of users to be created: ${process.env.USERS_FROM} to ${
    process.env.USERS_TO
  }`
);

if (argv.c) {
  //check if the default cluster admin password is present.
  if (argv.a) {
    console.log(
      "Default password for cluster admin is required run setup.js --help"
    );
    shell.exit(1);
  }
  //The OCP Cluster Admin password
  process.env.ADMIN_PASSWORD = argv.a;
  //Step-1
  // Create htpasswd file for users and add them to OpenShift
  var result = shell.exec(`${__dirname}/createUsers.sh`);

  if (result.code !== 0) {
    shell.echo(result.stderr);
    shell.exit(1);
  }
} else {
  console.log("Skipping user creation");
}
// //Step-2
result = shell.exec(`${__dirname}/addUsersToGroup.sh`);
if (result.code !== 0) {
  shell.echo(result.stderr);
  shell.exit(1);
}

//Step-3
result = shell.exec(`${__dirname}/configProjects.sh`);
if (result.code !== 0) {
  shell.echo(result.stderr);
  shell.exit(1);
}

//Step-4
result = shell.exec(`${__dirname}/addQuotaToProjects.sh`);
if (result.code !== 0) {
  shell.echo(result.stderr);
  shell.exit(1);
}
