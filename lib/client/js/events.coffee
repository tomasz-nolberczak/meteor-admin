Template.AdminLayout.events
	'click .btn-delete': (e,t) ->
		_id = $(e.target).attr('doc')
		if Session.equals 'admin_collection_name', 'Users' 
			Session.set 'admin_id', _id
			Session.set 'admin_doc', Meteor.users.findOne(_id)
		else
			Session.set 'admin_id', parseID(_id)
			Session.set 'admin_doc', adminCollectionObject(Session.get('admin_collection_name')).findOne(parseID(_id))

Template.AdminDeleteModal.events
	'click #confirm-delete': () ->
		collection = Session.get 'admin_collection_name'
		_id = Session.get 'admin_id'
		Meteor.call 'adminRemoveDoc', collection, _id, (e,r)->
			$('#admin-delete-modal').modal('hide')

Template.AdminDashboardUsersEdit.events
	'click .btn-add-role': (e,t) ->
		console.log TAPi18n.__("events.addingUser")
		Meteor.call 'adminAddUserToRole', $(e.target).attr('user'), $(e.target).attr('role')
	'click .btn-remove-role': (e,t) ->
		console.log TAPi18n.__("events.removingUser")
		Meteor.call 'adminRemoveUserToRole', $(e.target).attr('user'), $(e.target).attr('role')

Template.AdminHeader.events
	'click .btn-sign-out': () ->
		Meteor.logout ->
			Router.go(AdminConfig?.logoutRedirect or '/')

Template.AdminDashboardSettings.events
	'change #adminDashboardLanguage': (e, t) ->
		console.log(e.target.value)
		TAPi18n.setLanguage(e.target.value)
	'change #adminDashboardSkin': (e, t) ->
		console.log(e.target.value)
		_id = Session.get 'admin_id'
		Session.set 'adminSettings.skin', e.target.value
		Meteor.users.update({_id: _id}, {$set: {adminSettings: {skin: e.target.value}}})
		# Meteor.call 'adminSetDashboardSkin', _id, e.target.value