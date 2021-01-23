# opentutor.site (beanstalk app)

Use this repo to deploy the latest version (or any version) of opentutor to your own opentutor site as an [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) application.

## Deploying your site

The instructions below will guide you to set up an opentutor site, running on `AWS Elastic Beanstalk` for your own domain name.

### Prerequisites

You need an `AWS` account with your Elastic Beanstalk infrastructure already in place. You can use our [terraform template](https://github.com/opentutor/terraform-opentutor-aws-beanstalk) to build and maintain this infrastructure.

### Required Software

- unix shell
- git
- git lfs
- curl

### Creating the github (fork-LIKE) repo for your site

The goal is to allow you to manage your deployment without having to edit any code or configuration, other than some environment vars/secrets for the [github actions](https://github.com/features/actions) in your own copy of this repo. So keep that in mind when reading the instructions below.

**Step 1. Create and clone a repo for your site**

Do this the normal way in your github.com account. If you like name your repo the same as the domain name of your opentutor site + a suffix, e.g. `opentutor.yourdomain.org-beanstalk-app`

You probably want this repo to be private, and you can use whatever option to make sure your repo has its `main` branch with a first commit (e.g. choose the option to create a README when you create the repo). Whatever commits you put in this repo will just be overwritten with tagged versions the opentutor beanstalk-deployment repo.

**Step 2. Initialize your repo as a fork-like clone opentutor's [beanstalk-deployment](https://github.com/opentutor/beanstalk-deployment.git) repo**

In a unix terminal, cd to the root of your repo clone and then execute:

```bash
curl -s -H "Accept:application/vnd.github.v3.raw" https://api.github.com/repos/opentutor/beanstalk-deployment/contents/bin/init.sh | sh
```

This will change the `upstream` remote for your clone to the opentutor source repo, set up git lfs etc.

The result will end up being a lot like a fork, but it can't be an actual fork or `github actions` will not run for you.

### Configure your repo to deploy to your site using [github secrets](https://docs.github.com/en/actions/reference/encrypted-secrets)**

Before you can deploy a version of opentutor to your site, you need to configure your repo so github actions will deploy to the right account, instance, etc.

The goal is to allow you to use a fork-like clone of this repo to manage your deployment--including switching opentutor release versions--without having to edit code/config or do any complicated git merging. To enabled this, all the details that specify your site and AWS account are stored as `github secrets`. We use `github secrets` for config whether it's really secret or not because secrets is the mechanism `github actions` provides for configuring enviroment variables that can be accessed in `github actions`.

You will need to configure all of the following secrets:

 - *AWS_ACCESS_KEY_ID*
 - *AWS_SECRET_ACCESS_KEY*
 - *AWS_REGION*
 - *EBS_APP_NAME*
 - *EBS_ENV_NAME_PROD*
 - *EFS_FILE_SYSTEM_ID*

If you don't know what any or all of these values should be, whoever setup your Elastic Beanstalk infrastructure in AWS should be able to configure them in github secrets for you, and/or see the [terraform template](https://github.com/opentutor/terraform-opentutor-aws-beanstalk)

### Deploying a version of opentutor to your site domain

Once your repo is configured per above, follow these steps to deploy a version.

### Step 1. switch your clone to the desired version (or latest stable)

To switch your clone to the latest stable version of opentutor, open a terminal to the root of your repo and do

```bash
sh ./bin/version_switch.sh
```

...if you want a specific released version pass that version tag to the above, e.g.

```bash
sh ./bin/version_switch.sh 1.1.0
```

### Step 2. push to main

This needs to be a force push, e.g.

```
git push --force
```

### Step 3. Create a release tag to trigger the deployment

Github actions will deploy to your site when you [create a release](https://docs.github.com/en/github/administering-a-repository/managing-releases-in-a-repository#creating-a-release) that matches the expected semver format, e.g. `1.0.0` or `1.2.1`. The deploy job will also run on tags that have alphanumeric suffixes like `1.3.1-rc1`. In practice, it's hard to think of a case where the release you create in your repo wouldn't have the same version number as the tag you're releasing.

As soon as you create a release in the format described above, the deployment action should trigger in github actions.

## FAQ

### Why can't I just fork this repo for my site?

Github actions don't run on forked repositories

