// This is a manifest file that'll specifies the order in which these files will
// be compiled into application.js, which will include all the files listed
// below. This is the bare minimum load order necessary pipeline to work.
//
//  Saved vises take precedence
//= require ./savedVis
//
// These two provide the foundation for baseVis
//= require ./highmodifiers
//= require ./visUtils
//= require ./filters
//
// BaseVis holds up the other vises
//= require ./baseVis
//
// Any vises that are unabled to load rely on disabledVis
//= require ./disabledVis
//
// Scatter is the basis for Timeline
//= require ./scatter
//
// All other vises must be included before runtime
//= require ./map
//= require ./timeline
//= require ./bar
//= require ./histogram
//= require ./table
//= require ./summary
//= require ./photos
