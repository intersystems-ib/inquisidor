# Inquisidor
Inquisidor is an fully functional example of InterSystems IRIS functionalities working together with Angular project as front-end. In this project you will find examples of:
* Vector storage and Vector search.
* Foreign tables based on CSV files.
* Embedded Python for XML mapping.
* Columnar storage.


# What do you need to install? 
* [Git](https://git-scm.com/downloads) 
* [Docker](https://www.docker.com/products/docker-desktop) (if you are using Windows, make sure you set your Docker installation to use "Linux containers").
* [Docker Compose](https://docs.docker.com/compose/install/)
* [Visual Studio Code](https://code.visualstudio.com/download) + [InterSystems ObjectScript VSCode Extension](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript)

# Setup
Build the image we will use during the workshop:

```console
$ git clone https://github.com/intersystems-ib/inquisidor
$ cd workshop-inquisidor
$ docker-compose build
```

# Introduction

## What is this project for?

The goal of this project is to make accessible all the historic data of public tenders, making easy to get information searching tenders by description.

## How does this project work?

This project is designed as a common web application with a backend developed on InterSystems IRIS Community edition and a frontend developed on Angular.

## Backend

As we said before, our backend is developed on InterSystems IRIS technologies. The backend is responsible for:
* Get historic data from Spanish Public Tenders using [Embedded Python](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AFL_epython) capabilities, reading XML files and transforming it into ObjectScript objects.
* Vectorize descriptions to make available searchs by similarity.
* Receive and manage REST calls from the front-end.
* Generate iKnow index to accelerate searchs by free texts.
* Provide a JWT in order to securize the communication between frontend and backend.

## Frontend

Developed on Angular provides an easy to use user interface sending REST calls to the backend and receiving and managing the responses.

# Testing the project 
* Run the containers to deploy the backend and the frontend:
```
docker-compose up -d
```
Automatically an IRIS instance will be deployed and a production will be configured to import atom files with public tenders (you can find an example in folder **iris/shared/example**). If you want to include a automatic process to import files from the official web page you only need to create a new Business Service **Inquisidor.BS.ImportZipFile** and configure the folder to extract the files from the imported ZIP (the same that the path defined for **Licitaciones_IN** Business Service).
![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/automatic_import.png)

* Open the [Management Portal](https://localhost:8443/csp/sys/%25CSP.Portal.Home.zen?$NAMESPACE=INQUISIDOR).
* Login using the default `superuser`/ `SYS` account.
* Click on [Production](https://localhost:8443/csp/INQUISIDOR/EnsPortal.ProductionConfig.zen) to access the production that we are going to use. You can access also through *Interoperability > User > Configure > Production*.

Now you can check the frontend:
* Open the main page from this [URL](https://localhost/home).
  ![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/login.png)

* Login using `superuser` / `SYS` account.
* Click on the icon on the upper left of the screen and check the options of the menu.
  ![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/menu.png)

* Click on **Buscar licitación** to make searchs for published public tenders using description, publisher or CPV code.
  ![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/search_published.png)

* From **Buscar adjudicación** you have access to all the finished public tenders with information about the winners.
  ![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/winners.png)

* And you can compare and analyze the publishers and winners of public tender along the time from **Analisis de adjudicatarios** and **Analisis de licitadores** menus:

  Publishers:
  ![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/publisher_analisis.png)

  Winners:
  ![image](https://github.com/intersystems-ib/inquisidor/blob/main/assets/winners_analisis.png)