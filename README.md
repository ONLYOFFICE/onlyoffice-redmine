## ONLYOFFICE Redmine plugin

This plugin enables users to edit office documents from Redmine using ONLYOFFICE Docs packaged as Document Server - Community or Enterprise
Edition.

## Features
* Edit text documents, spreadsheets, and presentations.
* Co-edit documents in real-time: use two co-editing modes (Fast and Strict), Track Changes, comments, and built-in chat.

Supported formats:

* For editing: DOCX, XLSX, PPTX.
* For viewing only: DOC, DOCX, DOCM, DOT, DOTX, DOTM, ODT, FODT, OTT, RTF, TXT, HTML, HTM, MHT, XML, PDF, DJVU, FB2, EPUB, XPS, XLS, XLSX, XLSM, XLT, XLTX, XLTM, ODS, FODS, OTS, CSV, PPS, PPSX, PPSM, PPT, PPTX, PPTM, POT, POTX, POTM, ODP, FODP, OTP.

## Installing ONLYOFFICE Docs

You will need an instance of ONLYOFFICE Docs (Document Server) that is resolvable and connectable both from Redmine and any end clients. ONLYOFFICE Document Server must also be able to POST to Redmine directly.

You can install free Community version of ONLYOFFICE Docs or scalable Enterprise Edition with pro features.

To install free Community version, use [Docker](https://github.com/onlyoffice/Docker-DocumentServer) (recommended) or follow these [instructions](https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx) for Debian, Ubuntu, or derivatives.

To install Enterprise Edition, follow instructions [here](https://helpcenter.onlyoffice.com/installation/docs-enterprise-index.aspx).

Community Edition vs Enterprise Edition comparison can be found here.

## Installing ONLYOFFICE Redmine plugin

1. Install Redmine following the [instruction](https://www.redmine.org/projects/redmine/wiki/RedmineInstall). 

2. Download ONLYOFFICE integration plugin.
   You can either clone the master branch or download the latest zipped version. Before installing ensure that the Redmine instance is stopped.
    ````
    git clone https://github.com/ONLYOFFICE/onlyoffice-redmine
    wget https://github.com/ONLYOFFICE/onlyoffice-redmine
    ````

3. Put **onlyoffice_redmine** plugin directory into plugins. The plugins sub-directory must be named just **onlyoffice_redmine**. In case of need rename **onlyoffice_redmine-x.y.z** to **onlyoffice_redmine**.

4. Go to redmine directory `cd redmine`.

5. Install dependencies  `bundle install`.

6. Initialize/Update database:

   `RAILS_ENV=production bundle exec rake db:migrate`

   `RAILS_ENV=production bundle exec rake redmine:plugins:migrate NAME=redmine_dmsf`

7. You should configure the plugin via Redmine interface: **Administration -> Plugins -> Onlyoffice Redmine plugin -> Configure**.

## How it works

The ONLYOFFICE integration follows the API documented [here](https://api.onlyoffice.com/editors/basic):
