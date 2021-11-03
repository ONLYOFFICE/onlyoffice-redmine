# Redmine ONLYOFFICE integration plugin

This app enables users to edit office documents from [Redmine](https://www.redmine.org/) using ONLYOFFICE Docs packaged as Document Server - [Community or Enterprise Edition](#onlyoffice-docs-editions).

## Features

The app allows to:

* Edit text documents, spreadsheets, and presentations.
* Co-edit documents in real-time: use two co-editing modes (Fast and Strict), Track Changes, comments, and built-in chat.

Supported formats:

* For editing: DOCX, XLSX, PPTX.
* For viewing: DOC, DOCX, DOCM, DOT, DOTX, DOTM, ODT, FODT, OTT, RTF, TXT, HTML, HTM, MHT, XML, PDF, DJVU, FB2, EPUB, XPS, XLS, XLSX, XLSM, XLT, XLTX, XLTM, ODS, FODS, OTS, CSV, PPS, PPSX, PPSM, PPT, PPTX, PPTM, POT, POTX, POTM, ODP, FODP, OTP.

## Installing ONLYOFFICE Docs

You will need an instance of ONLYOFFICE Docs (Document Server) that is resolvable and connectable both from Redmine and any end clients. ONLYOFFICE Document Server must also be able to POST to Redmine directly.

You can install free Community version of ONLYOFFICE Docs or scalable Enterprise Edition with pro features.

To install free Community version, use [Docker](https://github.com/onlyoffice/Docker-DocumentServer) (recommended) or follow [these instructions](https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx) for Debian, Ubuntu, or derivatives.

To install Enterprise Edition, follow the instructions [here](https://helpcenter.onlyoffice.com/installation/docs-enterprise-index.aspx).

Community Edition vs Enterprise Edition comparison can be found [here](#onlyoffice-docs-editions).

## Installing Redmine ONLYOFFICE integration plugin

#### Minimum version of Redmine for ONLYOFFICE integration plugin is 4.0.0 .

1. If you're new to Redmine, install it following [these instructions](https://www.redmine.org/projects/redmine/wiki/RedmineInstall). 

2. Download Redmine ONLYOFFICE integration plugin.
   You can either clone the master branch or download the latest zipped version. Before installing, make sure that the Redmine instance is stopped.
    ````
    git clone https://github.com/ONLYOFFICE/onlyoffice-redmine
    ````

3. Put **onlyoffice_redmine** plugin directory into plugins. The plugins sub-directory must be named as **onlyoffice_redmine**. If necessary, rename **onlyoffice_redmine-x.y.z** to **onlyoffice_redmine**.

4. Go to the Redmine directory: `cd redmine`.

5. Install dependencies: `bundle install`.

6. Initialize/Update database:

   `RAILS_ENV=production bundle exec rake db:migrate`

   `RAILS_ENV=production bundle exec rake redmine:plugins:migrate NAME=onlyoffice_redmine`

## Configuring Redmine ONLYOFFICE integration plugin

Configure the plugin via the Redmine interface. Go to **Administration -> Plugins -> Onlyoffice Redmine plugin -> Configure** and specify the following parameters:

- **Document Editing Service address**:
  The URL and port of the installed ONLYOFFICE Document Server.

- **Secret key**:
  Enables JWT to protect your documents from unauthorized access (further information can be found [here](https://api.onlyoffice.com/editors/signature/)).

You can also configure the **Editor customization settings**:

- Display or hide Chat menu button

- Display the header more compact

- Display or hide Feedback & Support menu button 

- Display or hide Help menu button 

- Display monochrome toolbar header 

## How it works

The ONLYOFFICE integration follows the API documented [here](https://api.onlyoffice.com/editors/basic).

Redmine ONLYOFFICE integration plugin allows opening files uploaded to the Issues, Files, Documents, Wiki, or News modules for viewing and co-editing. For each module, the access rights to view/edit files depend on the settings (permissions) of the user role.

#### Issues module

Files added when creating a task or from comments to a task are available for viewing and editing.

File editing is available for user roles with the **Edit issues** permission.

Opening files for viewing is available for user roles with the **View issues** permission.

#### Files module

Files are available only for viewing for users who have the **View files** or **Manage files** permissions.

#### Documents module

The uploaded files in this module are available for viewing and editing.

Document editing is available for user roles with the **Edit documents** permission.

Opening documents for viewing is available for user roles with the **View documents** permission.

#### Wiki module

The uploaded files in this module are available for viewing and editing.

File editing is available for user roles with the **Edit Wiki pages** permission.

Opening files for viewing is available for user roles with the **View Wiki** permission.

#### News module

The uploaded files in this module are available for viewing and editing.

File editing is available for user roles with the **Edit news** permission.

Opening files for viewing is available for user roles with the **View news** permission.

#### Saving changes

All the changes made in the document are saved in the original file.

## ONLYOFFICE Docs editions

ONLYOFFICE offers different versions of its online document editors that can be deployed on your own servers. 

**ONLYOFFICE Docs** packaged as Document Server:

* Community Edition (`onlyoffice-documentserver` package)
* Enterprise Edition (`onlyoffice-documentserver-ee` package)

The table below will help you make the right choice.

| Pricing and licensing | Community Edition | Enterprise Edition |
| ------------- | ------------- | ------------- |
| | [Get it now](https://www.onlyoffice.com/download-docs.aspx#docs-community)  | [Start Free Trial](https://www.onlyoffice.com/download-docs.aspx#docs-enterprise)  |
| Cost  | FREE  | [Go to the pricing page](https://www.onlyoffice.com/docs-enterprise-prices.aspx)  |
| Simultaneous connections | Up to 20 maximum  | As in the chosen pricing plan |
| Number of users | Up to 20 recommended | As in the chosen pricing plan |
| License | GNU AGPL v.3 | Proprietary |
| **Support** | **Community Edition** | **Enterprise Edition** |
| Documentation | [Help Center](https://helpcenter.onlyoffice.com/installation/docs-community-index.aspx) | [Help Center](https://helpcenter.onlyoffice.com/installation/docs-enterprise-index.aspx) |
| Standard support | [GitHub](https://github.com/ONLYOFFICE/DocumentServer/issues) or paid | One year support included |
| Premium support | [Send a request](mailto:sales@onlyoffice.com) | [Send a request](mailto:sales@onlyoffice.com) |
| **Services** | **Community Edition** | **Enterprise Edition** |
| Conversion Service                | + | + |
| Document Builder Service          | + | + |
| **Interface** | **Community Edition** | **Enterprise Edition** |
| Tabbed interface                       | + | + |
| Dark theme                             | + | + |
| Scaling options                        | + | + |
| White Label                            | - | - |
| Integrated test example (node.js)      | + | + |
| Mobile web editors | - | + |
| Access to pro features via desktop     | - | + |
| **Plugins & Macros** | **Community Edition** | **Enterprise Edition** |
| Plugins                           | + | + |
| Macros                            | + | + |
| **Collaborative capabilities** | **Community Edition** | **Enterprise Edition** |
| Two co-editing modes              | + | + |
| Comments                          | + | + |
| Built-in chat                     | + | + |
| Review and tracking changes       | + | + |
| Display modes of tracking changes | + | + |
| Version history                   | + | + |
| **Document Editor features** | **Community Edition** | **Enterprise Edition** |
| Font and paragraph formatting   | + | + |
| Object insertion                | + | + |
| Adding Content controls         | - | + | 
| Editing Content controls        | + | + | 
| Layout tools                    | + | + |
| Table of contents               | + | + |
| Navigation panel                | + | + |
| Mail Merge                      | + | + |
| Comparing Documents             | - | + |
| **Spreadsheet Editor features** | **Community Edition** | **Enterprise Edition** |
| Font and paragraph formatting   | + | + |
| Object insertion                | + | + |
| Functions, formulas, equations  | + | + |
| Table templates                 | + | + |
| Pivot tables                    | + | + |
| Data validation                 | + | + |
| Conditional formatting | + | + |
| Sheet Views                     | - | + |
| **Presentation Editor features** | **Community Edition** | **Enterprise Edition** |
| Font and paragraph formatting   | + | + |
| Object insertion                | + | + |
| Transitions                     | + | + |
| Presenter mode                  | + | + |
| Notes                           | + | + |
| | [Get it now](https://www.onlyoffice.com/download-docs.aspx#docs-community)  | [Start Free Trial](https://www.onlyoffice.com/download-docs.aspx#docs-enterprise)  |