# opentutor.site (beanstalk app)

Use this repo to deploy the latest version (or any version) of opentutor to your own opentutor site as an [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) application.

## Deploying your site

The instructions below will guide you to set up an opentutor site, running on `AWS Elastic Beanstalk` for your own domain name.

### Prerequisites

You need an `AWS` account with your Elastic Beanstalk infrastructure already in place. You can use our [terraform template](https://github.com/opentutor/terraform-opentutor-aws-beanstalk) to build and maintain this infrastructure.

### Creating the github (fork-LIKE) repo for your site

The goal is to allow you to manage your deployment without having to edit any code or configuration, other than some environment vars/secrets for the [github actions](https://github.com/features/actions) in your own copy of this repo. So keep that in mind when reading the instructions below.

#### Step 1. Clone this repo

```
git clone https://github.com/opentutor/beanstalk-deployment.git 
```

## FAQ

- Why can't I just fork this repo for my site?




## Required software

- unix shell + make
- docker-compose
- make
- git + git lfs

## Running the app locally

#### .env secrets

Opentutor depends on some secret configuration to run (e.g. the `MONGO_URI` which includes password). In order to run the app locally, you will need a `.env` for the environment you're running. The default environment here is `opentutor-dev`, so the .env file goes at `env/opentutor-dev/.env`. Check with an admin to get the contents for that file.

#### git-lfs to pull model files

Larger model files like word2vec.bin are stored in git-lfs, so in order to run locally you need to pull lfs files explicitly. 

First you need to install `git-lfs` once for the clone:

`git lfs install`

Then, pull

`git lfs pull`

#### running the app in docker-compose via make

The app is set up to run locally in `docker-compose`, but it's easer to start it using make, e.g.

```
make run
```

## Cypress End-to-End Testing

#### To run Cypress tests:

```
make test-run
```

Then in a different terminal:

```
cd test
npm ci
npm run cy:open
```

#### To run Cypress tests inside of Docker:

```
make test
```
or
```
cd test
docker-compose -f ../docker-compose.yml -f docker-compose.yml up --exit-code-from cypress
```

#### To run Cypress tests inside of Docker with interactive GUI, you'll need to first set up X11 display:

- Install XQuartz with `brew cask install xquartz`
- Restart machine
- Open XQuartz with `open -a XQuartz`
- In the XQuartz preferences, go to the “Security” tab and make sure you’ve got “Allow connections from network clients” ticked

Then:

```
make test-with-ui
```
or
```
cd test
xhost +
docker-compose -f ../docker-compose.yml -f docker-compose.yml -f cypress-open.yml up --exit-code-from cypress
```