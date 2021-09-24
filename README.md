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

To install free Community version, use Docker[https://github.com/onlyoffice/Docker-DocumentServer] (recommended) or follow these instructions[https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx] for Debian, Ubuntu, or derivatives.

To install Enterprise Edition, follow instructions here[https://helpcenter.onlyoffice.com/installation/docs-enterprise-index.aspx].

Community Edition vs Enterprise Edition comparison can be found here.

## Installing ONLYOFFICE Redmine plugin

* steps

## How it works

The ONLYOFFICE integration follows the API documented here[https://api.onlyoffice.com/editors/basic]:
