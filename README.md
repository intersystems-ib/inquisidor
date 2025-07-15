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




## How does this project work?

This project is designed as a common web application with a backend developed on InterSystems IRIS Community edition and a frontend developed on Angular.

## Backend

As we said before, our backend is developed on InterSystems IRIS with IntegratedML technologies. The backend is responsible for:
* Get historic results of Spanish League from an external web using webscrapping with [Embedded Python](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AFL_epython) capabilities.
* Prepare the data get from the external web to be used by the prediction model.
* Create model and train with the prepared data using the [IntegratedML](https://docs.intersystems.com/iris20232/csp/docbook/Doc.View.cls?KEY=GIML_Intro) capabilities.
* Receive and manage REST calls from the front-end.
* Generate predictions for the matches.
* Provide a JWT in order to securize the communication between frontend and backend.

## Frontend

Developed on Angular provides an easy to use user interface sending REST calls to the backend and receiving and managing the responses.

# Testing the project 
* Run the containers to deploy the backend and the frontend:
```
docker-compose up -d
```
Automatically an IRIS instance will be deployed and a production will be configured and run available to import data to create the prediction model and train it.

* Open the [Management Portal](http://localhost:52774/csp/sys/%25CSP.Portal.Home.zen?$NAMESPACE=QUINIELA).
* Login using the default `superuser`/ `SYS` account.
* Click on [Production](http://localhost:52774/csp/QUINIELA/EnsPortal.ProductionConfig.zen) to access the production that we are going to use. You can access also through *Interoperability > User > Configure > Production*.

Now you can check the frontend:
* Open the main page from this [URL](http://localhost:4200).
  ![image](https://github.com/intersystems-ib/workshop-quiniela/blob/main/assets/login.png)

* Login using `superuser` / `SYS` account.
* Click on the icon on the upper left of the screen and check the options of the menu.
  ![image](https://github.com/intersystems-ib/workshop-quiniela/blob/main/assets/menu.png)

* Click on Data management and follow the arrows: Launch import -> Launch preparation -> Launch training. Wait for the end of each step.
* Now open the Menu again and click on Result prediction.
* You can add all the matches and see the prediction.
![image](https://github.com/intersystems-ib/workshop-quiniela/blob/main/assets/import.png)
* You can keep the data updated adding the real result clicking on the match and introducing the result:
![image](https://github.com/intersystems-ib/workshop-quiniela/blob/main/assets/predict.png)


