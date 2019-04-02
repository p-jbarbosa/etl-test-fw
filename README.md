# README

- [README](#readme)
  - [ETL-Dummy Project](#etl-dummy-project)
  - [How to Use it](#how-to-use-it)
  - [ETL Test Library](#etl-test-library)
    - [Data Entity Definition](#data-entity-definition)
    - [Folder Structure](#folder-structure)
    - [How ETF works](#how-etf-works)
      - [jb-execute-test](#jb-execute-test)
      - [jb-prepare-test-environment](#jb-prepare-test-environment)
    - [How to Build one Test Artifact](#how-to-build-one-test-artifact)
    - [Artifact List](#artifact-list)
  - [Jmeter Test Plans](#jmeter-test-plans)
    - [Local Test Plan](#local-test-plan)
    - [Remote Test Plan](#remote-test-plan)
    - [Test Configurations](#test-configurations)
      - [Test Configuration Files Location](#test-configuration-files-location)
    - [How to install Jmeter](#how-to-install-jmeter)

This project purpose is to deliver an approach to a centralized ETL Test framework - approach in the sense that it is not official and still needs validation. It holds reusable code made for kettle execution (you can think of this as the begining of a common ETL Test Library), and Jmeter reusable test plans that can orchestrate test scenarios composed by several steps.

## ETL-Dummy Project

The present documentation is using an etl-dummy project to explain the concepts that are supporting this approach. The project is made of two main repositories:

- etl-dummy
  - the ETL code
  - [github repo](https://github.com/p-jbarbosa/etl-dummy)
- etl-dummy-configs
  - the configurations
  - [github repo](https://github.com/p-jbarbosa/etl-dummy-configs)

The folder structure of this project after cloning the different projects should be similiar to this one:

``` txt
FWs-Sandbox/
├── etl-dummy
├── etl-dummy-configs
├── etl-test-framework
├── input-files
├── output-files
└── test-results
```

## How to Use it

The ETL Test Framework (ETF) can be used to run tests over an ETL project either by executing the available ETL Test components from their Library, on isolated kettle executions, or by executing Test Configurations, via Jmeter, that represent a complete test scenario - for example, a test scenario could be made by three steps: first step could be prepare the environment to run the ETL, the second step execute the ETL that we want to test, and the third step performing the validation on the data that resulted from the ETL execution.

The ETF is added to an ETL project by cloning the current project to the Main Project folder and by creating/filling the necessary properties under the _kettle.properties_ and property environment files. 

The lines on _kettle.properties_ necessary to link the ETF to the project are:

- ETL_TEST_FRAMEWORK_DIR=/local/path/to/etl-test-framework
- ETL_TEST_FRAMEWORK_HOME=/path/to/the&framework/code (it could be a PUC path)

Beyond these properties, the ETF also requires the different etl projects to add one property to their _project_.properties file. For etl-dummy project we need to add the following property to the _../properties/etl-dummy.properties_ file:

- ENTITIES_HOME=/path/to/the/entites/folder/under/the/sub-project

Ideally, ETF is cloned into the Main Project directory, like the example below:

``` sh
FWs-Sandbox/
├── etl-dummy
├── etl-dummy-configs
├── etl-test-framework
├── input-files
├── output-files
└── test-results
```

On this example, _FWs-Sanbox_ is the Main Project directory, _etl-dummy_ is the folder that holds the ETL code, _etl-dummy-configs_ is the configurations keeper and _etl-test-framework_ is the ETF main folder.

## ETL Test Library

The idea behind is to have a library of reusable tests that can be shared and used for different PDI projects.

The requirements that are considered to make it indepent are:

- it should be kept under a separated git project so we can apply different rules to control it
- all provided test tools should be project agnostic and rely only on configuration files and data Entity Definitions
- it should enforce code rules as much as possible, like filename structures, using for example git hooks to keep important standards to her executions
- it should always be executed inside their on code structure and not rely on any project code except configuration and data Entity Definitions
- it should supply tools to prepare test environments before the test executions

### Data Entity Definition

This is a concept dedicated to solve the problem of sharing execution information between the ETL project and the ETL Test Framework. Beyond the project configurations, to build a shared library of tests the ETL Test Framework needs information about the entities that should be used during the test execution. Information such as tables where information should be fetched, fields/attributes that we need to consider for specific test purposes, connection names that should be used to obtain data, or files that hold the correct information that should be used by ETL Test Framework to compare values. This information must be supplied to the ETL Test Framework at run time, so their tools could be reused be different projects.

The data Entity Definition can be the tool to link the ETL code and the ETL Test Framework. A Data Entity Definition is currently a json file with the attributes that are necessary to the test tools available. Below is an example for the Entity _LegalHold_ used under the etl-dummy project.

``` json
{
    "connections": {
        "etl":"legalHold",
        "tests": "legalHold_ETF"
    },
    "primaryKey": "",
    "mainTable": "legalhold_list",
    "tableToCompare": "legalhold_correct",
    "fieldsToCompare": "LegalHold,Flag",
    "fieldsToOrderBy": "LegalHold",
    "producesOutputFiles": "Y",
    "testInformation":{
        "prepare-environment-destructive": "Y",
        "outputfile-extension-to-delete": "csv"
    }
}
```

The attributes specify the elements that are requested by the ETF.

- connections, represent the connection names that can should be used by ETF when using steps that need this info
- primaryKey, to refer the Entity primary key
- mainTable, is the sql table receiving the Entity data
- tableToCompare, is the sql table that keeps the correct data that can be used to compare results
- fieldsToCompare, can keep the attributes that we want to compare when testing stuff
- fieldsToOrderBy, the Entity fields that should be considered to help obtain results that are comparable
- testInformation - general information about the test that, for instance, help to prepare environment

The ETL Test Framework is expecting this files to be inside each of the ETL projects folder that are currently controlled by the Project, under a speficic folder called _entities_, and then divided by the Entities names. Under the _etl-dummy_ project the _LegalHold_ Entity is at:

``` txt
etl-dummy/
├── entities
│   └── LegalHold
│       └── definition.json
```

The path to the _entities_ folder for each project is controlled by the property ENTITES_HOME, defined under each _project_,properties.

### Folder Structure

The ETL Test Framework has the following folder structure:

```txt
etl-test-framework/
├── bin
├── compare
├── execution
├── external-resources
├── helpers
└── utilities
```

- _bin_ - is the folder that should hold all the ETF necessary shell scripts
- _compare_ - this folder is responsible to keep all the content that performs tests based on comparisons, such as table-to-table comparison. Different test operations should have different parent folders
- _execution_ - here we put every element that make ETF executions. ETF executions are centralized on entry points to increase control
- _external-resources_ - here are collected all the external resources that are used/controlled by ETF, such as Jmeter Test Plans
- _helpers_ - all the small reusable tasks available to each Test Artifact such as load test environments, or compile results
- _utilities_ - ETF artifacts that are useful to execute outside the regular ETF execution path.

### How ETF works

The ETL Test Framework was built around the idea of execution entry points to be called by the outside world (kitchen or Jmeter Test Configurations). These execution entry points represent the way to execute operations provided by the ETF such as prepare environment for tests, or perform comparisons to determine if the produced data is correct. This way we can control the test execution environment and also standardize the way all test artifacts work and use parameters.

The ETF provides the following execution entry points:

- ../execution/jb-execute-test.kjb - responsible by all the executions related with data quality tests
- ../utilities/jb-prepare-test-environment.kjb - an utility to create/prepare environments (truncate tables, remove files, etc). Still a work in progess, even more than the other ones.

#### jb-execute-test

This is the main executor. All tests should be started calling this job. His executions are divided into 3 main stages:

1. collect the necessary information to run the test artifact (variables and parameters)
1. call the test artifact that will be executed
1. digest the data retrieved by the test artifact

An ETF test execution is always a call to this job with the set of parameters defining the test we wanto to execute. The parameters are:

- P_PROJECT_NAME - the ETL project that controls the Entity to be tested, under our example it should be _etl-dummy_
- P_ENTITY - the Entity that will be tested, on _etl-dummy_ it is Entity _LegalHold_; this is the Entity that will provide the Data Entity Definition
- P_TEST_OPERATION - the name of the test operation we would like to perform; currently ETF only as _compare_
- P_TEST_ELEMENT - the test we would like to execute under the Test Operation previously defined
- P_FILTER_DATA - if necessary, a way to filter the data that should be considered to the final comparison
- P_EXPECTED_VALUE - if necessary, a value that will be used as a reference during test comparison

The first stage set the necessary parameters and variables necessary to the execution. Some of those come from the Data Entity Definitions that is appointed by the P_ENTITY value. This .json files are located under the ETL project, so during this stage we have to load the _project-name_.properties file that is responsible to maintain the project properties.

Calling the test artifact, or the Test Element under the selected test operation, is made through the usage of some of those parameters on a job entry:

``` txt
${ETL_TEST_FRAMEWORK_DIR}/${P_TEST_OPERATION}/jb-executor-${P_TEST_ELEMENT}.kjb
```

This enforces three important things:

- Test Elements are grouped under Test Operations; Test Operation _compare_ as two Test Elements, _table-to-table_ and _count-from-table_
- all Test Elements must have a job, lcoated under the correspondent Test Operation folder
- all Test Elements must start with the prefix _jb-executor-_

The last stage, the ETF test digestion, is controlled by two variables:

- V_ERRORS - and integer the amount of errors detected; when different from zero the ETF ends the execution with an error
- V_ERROR_MSG - a text field with the message explaining the errors

All developed Test Elements should create and instantiate these variables to help _jb-execute-test_ perform correctly.

#### jb-prepare-test-environment

This is a very simple utility, still in a very early age, which is to say that the current implementation only has the merit of signal his importance. What we are trying to achieve here is a clean utility that can deal with data test environment preparation: truncate tables, or remove output files, clinical inserts, and so on.

This utility is meant to be used outside the regular _jb-execute-test_ executor to enforce a clear separation between these two services - eventually, at least the parameters will be different and one thing is to execute a Test other will be to execute a preparation environment.

This service execution is divided into 2 stages:

- getting information about how to prepare the environment, based on the Project Name and Entity that will be used on the following test
- and, prepare the environment, which for now consists of truncating tables and delete files

To execute this operations the services needs to receive these paramters:

- P_PROJECT_NAME - the project that tracks the testing Entity
- P_ENTITY - the preparation scope object where the ETF is going to fetch the Data Entity Definition

Next work would be to add more use cases to this preparation and improve the information available on the Data Entity Definition .json file (currently is confusing).

### How to Build one Test Artifact

ToDo.

### Artifact List

ToDo.

## Jmeter Test Plans

Apache JMeter is open source software, a 100% pure Java desktop application, designed to load **test functional** behavior and measure performance of web sites. It was originally designed for load testing web applications but has since expanded to other test functions.

On the ETL Test Framework (ETF) we are exploring it to execute **Test Configurations** and leveraging Jmeter capabilities to execute and measure processes.

The main idea is to provide 2 abstract Jmeter Test Plans that can execute **Test Configurations** for the ETL projects that are plug into ETF.

ETF provides 2 abstract Jmeter Test Plans: one to be executed through Jmeter installed on the same machine as the ETL code, and another to be executed through Jmeter installed on a different machine using the SSH protocol to execute the ETL.

### Local Test Plan

This implementation uses the Jmeter Test Plan _../etl-test-framework/external-resources/jmeterTestPlans/to-certify.jmx_.

This Jmeter Test Plan Strategy is based on three Jmeter main concepts:

1. A _setUP Thread Group_ to validate the Test Plan inputs and to assign necessary variables values, including the number of loop the next Thread Group will execute
2. A _Thread Group_ that will be executed for every line available on the test plan .csv file
   1. _CSV Data Set Config_ that will load the information to execute the next test execution
   2. A _OSS Process Sampler_ to start the job through the project kitchen.sh
   3. A _Response Code Assertion_ to check the expected test plan execution status against the status received form the execution

It receives the follow input paramters:

- Entity - the name of the entity that is being tested. Allows the Jmeter Test Plan to point to the correct Test Configuration .csv file and the ETF to load information to be used if a ETF Library artifact should be used
- TestConfiguration - the name of the Test Configuration .csv file that will be executed
- BaseDir - the complete path to the Main Project Folder
- ProjectName - the Project folder name that holds the Information Entity we are going to test
- ProjectConfigurationsDir - the folder that holds all the available configurations
- Environment - the configuration environment that should be used when executing the tests

Command to execute it via UI:

``` sh
./jmeter.sh -JEntity=LegalHold -JTestConfiguration=load-scda -JBaseDir=/home/malskat/sandbox/FWs-Sandbox -JProjectName=etl-dummy -JProjectConfigurationsDir=etl-dummy-configs -JEnvironment=local -t /home/malskat/sandbox/FWs-Sandbox/etl-test-framework/external-resources/jmeterTestPlans/to-certify.jmx
```

### Remote Test Plan

This implementation uses the Jmeter Test Plan _../etl-test-framework/external-resources/jmeterTestPlans/remote-to-certify.jmx_.

This Jmeter Test Plan receives the follow input paramters:

- Host - the ip address to the machine where the ETL code is located
- Port - the ssh port used to connect to the remote machine
- User - the username that will be used on the ssh connection
- Password - the password that will be used on the ssh connection
- Entity - the name of the entity that is being tested. Allows the Jmeter Test Plan to point to the correct Test Configuration .csv file and the ETF to load information to be used if a ETF Library artifact should be used
- TestConfiguration - the name of the Test Configuration .csv file that will be executed
- BaseDir - the complete path to the Main Project Folder
- ProjectName - the Project folder name that holds the Information Entity we are going to test
- ProjectConfigurationsDir - the folder that holds all the available configurations
- Environment - the configuration environment that should be used when executing the tests

The implementation is similar to the _Local_ one, with the exception that the executed kitchen.sh is made via ssh protocol, using the _SSH Protocol Plugin_ installed on Jmeter.

Command to execute via UI:

``` sh
./jmeter.sh -JHost=[host-ip-address] -JPort=22 -JUser=[remote-user] -JPassword=[remote-password] -JEntity=LegalHold -JTestConfiguration=load-scda -JBaseDir=/home/malskat/sandbox/FWs-Sandbox -JProjectName=etl-dummy -JProjectConfigurationsDir=etl-dummy-configs -JEnvironment=local -t /home/malskat/sandbox/FWs-Sandbox/etl-test-framework/external-resources/jmeterTestPlans/remote-to-certify.jmx
```

### Test Configurations

**Test Configurations** are a sequence of steps that represent the whole test scenario to be performed. One **Test Configuration** can be divided into 3 steps, for instance:

- prepare the environment to execute the ETL
- execute the ETL
- evaluate the data produced by the ETL execution

They are represented by .csv files, where each line describes the step to be executed by PDI via kitchen - currently only kitchen is supported. We can execute ETF code and project ETL.

Each Test Configuration step is described by the following fields:

- objectContainer - the relative path to the folder that holds the ETL code to execute
- objectToExecute - the name of the job that should be executed
- objectParams - the parameters that the job requires using the structure expected by kitchen
- expectedStatus - the status that we expect after running these step, 0 for OK, 1 for not ok (remember that we might want to test if the current step throws an error)

#### Test Configuration Files Location

Test Configuration .csv files are considered Project related content, so the ETF and the JMeter Test Plan are expecting to find them at a specific location within the Project ETL Folder. This location is then segmented by the Information Entity that is the scope of that Test Configuration. 

For an example lets considered our project with the name _etl-dummy_ within a Main Project folder structure like this:

``` sh
FWs-Sandbox/
├── etl-dummy
├── etl-dummy-configs
├── etl-test-framework
├── input-files
├── output-files
└── test-results
```

Inside _etl-dummy_ a special folder, named _test-configurations_ sould hold the .csv files that represent the Test Configurations for each considered entity. The structure below represents the folder structure inside _etl-dummy_:

``` sh
├── content-pdi
├── entities
│   └── LegalHold
├── logs
├── sql
│   └── LegalHold
└── test-configurations
    └── LegalHold

```

On the previous example _LegalHold_ folder, under _test-configurations_ is an Information Entity that as 2 Test Configuration scenarios.

### How to install Jmeter

Jmeter is easy to install. For reference you can follow [this](https://www.youtube.com/watch?v=M-iAXz8vs48&list=PLhW3qG5bs-L-zox1h3eIL7CZh5zJmci4c&index=2&t=0) tutorial.

To execute the remote test plan we need to install _Jmeter Manager Plugin_ and _SSH Protocol Support Plugin_.

To install _Manager Plugin_ you can follow [this](https://jmeter-plugins.org/wiki/PluginsManager/).

Install the SSH Protocol Support using the _JMeter Manager Plugin_.