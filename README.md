# README

- [README](#readme)
  - [How to Use it](#how-to-use-it)
  - [ETL Test Library](#etl-test-library)
    - [Data Entity Definition](#data-entity-definition)
    - [Folder Structure](#folder-structure)
    - [Test Artifacts](#test-artifacts)
  - [Jmeter Test Plans](#jmeter-test-plans)
    - [Local Test Plan](#local-test-plan)
    - [Remote Test Plan](#remote-test-plan)
    - [Test Configurations](#test-configurations)
      - [Test Configuration Files Location](#test-configuration-files-location)
    - [How to install Jmeter](#how-to-install-jmeter)

This project purpose is to deliver an approach to a centralized ETL Test framework - approach in the sense that it is not official and still needs validation. It holds reusable code made for kettle execution (you can think of this as the begining of a common ETL Test Library), and Jmeter reusable test plans that can orchestrate test scenarios composed by several steps.

## How to Use it

The ETL Test Framework (ETF) can be used to run tests over an ETL project either by executing the available ETL Test components from their Library, on isolated kettle executions, or by executing Test Configurations, via Jmeter, that represent a complete test scenario - for example, a test scenario could be made by three steps: first step could be prepare the environment to run the ETL, the second step execute the ETL that we want to test, and the third step performing the validation on the data that resulted from the ETL execution.

The ETF is added to an ETL project by adding the path to the local main folder on the project's _kettle.properties_. By doing this we can run the ETL using the same kitchen that we use to run the ETL project code. The line on _kettle.properties_ should be:

> ETL_TEST_FRAMEWORK_DIR=/local/path/to/etl-test-framework

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

On this example, _FWs-Sanbox_ is the Main Project rdirectory, _etl-dummy_ is the folder that holds the ETL code, _etl-dummy-configs_ is the configurations keeper and _etl-test-framework_ is the ETF main folder.

## ETL Test Library

The idea behind this is to have a library of reusable tests that can be shared and used for any PDI project.

The requirements that are considered to make it indepent are:

- it should be kept under a separated git project
- all provided tools should be project agnostic and rely only on configuration files and data entity definitions
- it should enforce code rules as much as possible, like filename structures, using for example git hooks to keep important standards to her executions
- it should always be executed inside their on code structure and not rely on any project code except configuration and data entity definitions
- it should have tools to prepare test environments before the test executions

### Data Entity Definition

This is a concept dedicated to solve the problem of sharing execution information between the ETL project and the ETL Test Framework. Beyond the project configurations, to build a shared library of tests the ETL Test Framework needs information about the entities that should be used during the test execution. Information such as tables where information should be fetched, fields that we need to consider for test purposes, connection names that should be used to obtain information, or files that hold the correct information that should be used by ETL Test Framework to compare values.

The data entity definition can be the tool to link the ETL code and the ETL Test Framework. A Data Entity Definition is currently a json file with the attributes that are necessary to the table to table compare service. Above is the example for the Entity LegalHold used under the etl-dummy project.

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
    "produces-output-files": "Y",
    "test-information":{
        "prepare-environment-destructive": "Y",
        "outputfile-extension-to-delete": "csv"
    }
}
```

### Folder Structure

ToDo.

### Test Artifacts

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