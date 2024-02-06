# Changelog

## 3.0.1
## Bug Fixes

- Support for the Document Server URL with virtual path.
- Support for the Redmine "Authentication Required" setting.

## 3.0.0
## Breaking Changes

- Support for Redmine versions below 4.2 has been dropped.
- Support for Internet Explorer (IE) has been dropped.
- The ability to create a document (not an attachment) has been removed.
- Migration from Ruby version 2 to 3 has been implemented.
- Users can now edit an attachment even if the issue is closed.
- Support for new formats has been added.
- User permissions have been improved for more accurate functionality.

## Features

- Added support for Redmine located in a subdirectory.
- Replaced icons with more intuitive ones.
- Changed the conversation from synchronous to asynchronous.
- Added a dedicated page for the "Create in" action.
- Users can now change the name and add a description when creating an attachment.
- Added support for the user's language preferences when creating an attachment.
- Combined the "Save as" and "Download as" actions onto one page.
- Added the ability to add a description when converting a attachment.
- Users can now select from available formats for editing.
- Added the ability to view, edit, and convert attachments on the forums page.
- Added the ability to edit and convert attachments on the files page.

## Bug Fixes

- Fixed the issue of settings not being saved even if validation fails.
- Implemented a native file-saving process and fixed filename issues containing underscores.

## Chores

- Added ONLYOFFICE Docs Cloud banner on the settings page of the plugin.
- Fixed formatting issues and ensured codebase uniformity.
- Updated the appearance of the settings page of the plugin.
- Updated README.

## 2.1.0
## Added
- jwt header configuration

## 2.0.0
## Added
- documents conversion
- Added connection to a demo document server
- Document Editing Service address is now splitted in two settings: inner address (address that confluence will use to access service) and public address (address that user will use to access editors)
- validation of server settings on the settings page
- ignoring self signed certificate

## Fixed
- issue with permissions

## 1.1.0
## Added
- ability to create documents
- support docxf and oform formats
- create blank docxf from creation menu
- "save as" in editor

## 1.0.0
## Added
- configuration page of plugin
- coediting docx, xlsx, pptx
- customization document editor view
- add goBack url for document editor
- change favicon in editor by document type
- detecting mobile browser
