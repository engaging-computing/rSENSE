/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
  // Defines a toolbar with only one strip containing the "Source" button, a
  // separator and the "Bold" and "Italic" buttons.


  // Similar to example the above, defines a "Basic" toolbar with only one strip containing three buttons.
  // Note that this setting is composed by "toolbar_" added by the toolbar name, which in this case is called "Basic".
  // This second part of the setting name can be anything. You must use this name in the CKEDITOR.config.toolbar setting,
  // so you instruct the editor which toolbar_(name) setting to use.
  config.toolbar_Basic = [
      {name: 'styles', items : [ 'Source', '-', 'Bold', 'Italic', 'Underline','-','NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-', 'Image' ]},
      {name: 'sizes', items: ['Format']}
  ];
  // Load toolbar_Name where Name = Basic.
  config.toolbar = 'Basic';
  


  config.removePlugins = 'contextmenu,liststyle,tabletools';
};

