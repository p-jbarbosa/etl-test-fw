# README

This project purpose is to deliver an approach to a centralized ETL Test framework - approach in the sense that it is not official and still needs validation. It holds reusable code made for kettle execution (you can think of this as the begining of a common ETL Test Library), and Jmeter reusable test plans that can orchestrate test scenarios composed of several steps.

## How to Use it

The ETL Test Framework (ETF) can be used to run tests over an ETL project either by executing the available ETL Test components from their Library, on isolated kettle executions, or by executing Test Configurations, via Jmeter, that represent a complete test scenario - for example, first step could be prepare the environment to run the test, the second step execute the ETL that we want to test, and the third performing the validation on the data that resulted from the ETL execution.

The ETF is added to an ETL project by adding the path to the local main folder on the project's _kettle.properties_. By doing this we can run the ETL using the same kitchen that we use to run the ETL project code. The line on _kettle.properties_ should be:

> ETL_TEST_FRAMEWORK_DIR=/local/path/to/etl-test-framework

Ideally, ETF is cloned into the main Project directory, under a folder structure similar to this one:

``` sh
FWs-Sandbox/
├── etl-dummy
├── etl-dummy-configs
├── etl-dummy-configurations
├── etl-test-framework
├── input-files
├── output-files
└── test-results
```

Under this example, _FWs-Sanbox_ is the project root folder, _etl-dummy_ is the folder that holds the ETL code, _etl-dummy-configs_ is the configurations keeper and _etl-test-framework_ is the ETF main folder.

## ETL Test Library

**ToDo**.

## Jmeter Test Plans

Apache JMeter is open source software, a 100% pure Java desktop application, designed to load **test functional** behavior and measure performance of web sites. It was originally designed for load testing web applications but has since expanded to other test functions.

On the ETL Test Framework (ETF) we are exploring it to execute **Test Configurations** and leveraging Jmeter capabilities to execute and measure processes.

The main idea is to provide 2 abstract Jmeter Test Plans that can execute **Test Configurations** for the ETL projects that are plug into ETF.

ETF provides 2 abstract Jmeter Test Plans: one to be executed through Jmeter installed on the same machine as the ETL code, and another to be executed through Jmeter installed on a remote machine using the SSH protocol.

### Test Configurations

**Test Configurations** are a sequence of steps that represent the whole test scenario to be performed. One **Test Configuration** can be divided into 3 steps:

* prepare the environment to execute the ETL
* execute the ETL
* evaluate the data produced by the ETL execution

They are represented by .csv files where each line describes the step to be executed by kitchen - currently on kitchen is supported. We can execute ETF code and project ETL.

The .csv files are composed by the following fields:

* objectContainer - the relative path to the folder that holds the ETL code to execute
* objectToExecute - the name of the job that should be executed
* objectParams - the parameters that the job requires using the structure expected by kitchen
* expectedStatus - the status that we expect after running these step, 0 for OK, 1 for not ok (remember that we might want to test if the current step throws an error)

### How to install Jmeter

Jmeter is easy to install. For reference you can follow [this](https://www.youtube.com/watch?v=M-iAXz8vs48&list=PLhW3qG5bs-L-zox1h3eIL7CZh5zJmci4c&index=2&t=0) tutorial.

To execute the remote test plan we need to install _Jmeter Manager Plugin_ and _SSH Protocol Support Plugin_.

To install _Manager Plugin_ you can follow [this](https://jmeter-plugins.org/wiki/PluginsManager/).

Install the SSH Protocol Support using the _JMeter Manager Plugin_.

### Local Test Plan

Command to execute via UI:

``` sh
./jmeter.sh -JEntity=LegalHold -JTestConfiguration=load-scda -JBaseDir=/home/malskat/sandbox/FWs-Sandbox -JProjectName=etl-dummy -JProjectConfigurationsDir=etl-dummy-configs -JEnvironment=local -t /home/malskat/sandbox/FWs-Sandbox/etl-test-framework/external-resources/jmeterTestPlans/to-certify.jmx
```

### Remote Test Plan

Command to execute via UI:

``` sh
./jmeter.sh -JHost=[host-ip-address] -JPort=22 -JUser=[remote-user] -JPassword=[remote-password] -JEntity=LegalHold -JTestConfiguration=load-scda -JBaseDir=/home/malskat/sandbox/FWs-Sandbox -JProjectName=etl-dummy -JProjectConfigurationsDir=etl-dummy-configs -JEnvironment=local -t /home/malskat/sandbox/FWs-Sandbox/etl-test-framework/external-resources/jmeterTestPlans/remote-to-certify.jmx
```