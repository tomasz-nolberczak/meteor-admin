@AdminController = RouteController.extend
	layoutTemplate: 'AdminLayout'
	waitOn: ->
		customSubscriptions = _.reduce AdminConfig?.collections, (subscriptions, collection) ->
			subscriptions.push collection.countSubscription() if collection.countSubscription
			subscriptions
		, []
		_.union [
			Meteor.subscribe 'adminUsers'
			Meteor.subscribe 'adminUser'
			Meteor.subscribe 'adminCollectionsCount'
		], customSubscriptions
	onBeforeAction: ->
		Session.set 'adminSuccess', null
		Session.set 'adminError', null

		Session.set 'admin_title', ''
		Session.set 'admin_subtitle', ''
		Session.set 'admin_collection_page', null
		Session.set 'admin_collection_name', null
		Session.set 'admin_id', null
		Session.set 'admin_doc', null

		if not Session.get "admin_skin_loaded"
			Session.set "admin_skin_loaded", false
			Session.set "admin_skin", false
			Session.set "admin_language", false
			Meteor.call 'adminGetSettings', Meteor.userId(), (e,r)->
				Session.set "admin_skin", r.skin
				Session.set "admin_language", r.language
				Session.set "admin_skin_loaded", true
				TAPi18n.setLanguage r.language

		if not Roles.userIsInRole Meteor.userId(), ['admin']
			Meteor.call 'adminCheckAdmin'
			if typeof AdminConfig?.nonAdminRedirectRoute == 'string'
				Router.go AdminConfig.nonAdminRedirectRoute

		@next()


Router.route "adminDashboard",
	path: "/admin"
	template: "AdminDashboard"
	controller: "AdminController"
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Dashboard'
		Session.set 'admin_collection_name', ''
		Session.set 'admin_collection_page', ''

Router.route "adminDashboardUsersView",
	path: "/admin/Users"
	template: "AdminDashboardView"
	controller: "AdminController"
	action: ->
		@render()
	data: ->
		admin_table: AdminTables.Users
	onAfterAction: ->
		Session.set 'admin_title', 'Users'
		Session.set 'admin_subtitle', 'View'
		Session.set 'admin_collection_name', 'Users'

Router.route "adminDashboardUsersNew",
	path: "/admin/Users/new"
	template: "AdminDashboardUsersNew"
	controller: 'AdminController'
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Users'
		Session.set 'admin_subtitle', 'Create new user'
		Session.set 'admin_collection_page', 'New'
		Session.set 'admin_collection_name', 'Users'

Router.route "adminDashboardUsersEdit",
	path: "/admin/Users/:_id/edit"
	template: "AdminDashboardUsersEdit"
	controller: "AdminController"
	data: ->
		user: Meteor.users.find(@params._id).fetch()
		roles: Roles.getRolesForUser @params._id
		otherRoles: _.difference _.map(Meteor.roles.find().fetch(), (role) -> role.name), Roles.getRolesForUser(@params._id)
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Users'
		Session.set 'admin_subtitle', 'Edit user ' + @params._id
		Session.set 'admin_collection_page', 'edit'
		Session.set 'admin_collection_name', 'Users'
		Session.set 'admin_id', @params._id
		Session.set 'admin_doc', Meteor.users.findOne({_id:@params._id})

Router.route "adminDashboardSettings",
	path: "/admin/settings"
	template: "AdminDashboardSettings"
	controller: 'AdminController'
	data: ->
		user: Meteor.users.find(@params._id).fetch()
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Settings'
		Session.set 'admin_subtitle', 'Change dashboard settings'