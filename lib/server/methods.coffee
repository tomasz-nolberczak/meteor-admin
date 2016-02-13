Meteor.methods
	adminInsertDoc: (doc,collection)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			this.unblock()
			result = adminCollectionObject(collection).insert doc
				
			return result

	adminUpdateDoc: (modifier,collection,_id)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			this.unblock()
			result = adminCollectionObject(collection).update {_id:_id},modifier
			return result

	adminRemoveDoc: (collection,_id)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			if collection == 'Users'
				Meteor.users.remove {_id:_id}
			else
				# global[collection].remove {_id:_id}
				adminCollectionObject(collection).remove {_id: _id}


	adminNewUser: (doc) ->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			emails = doc.email.split(',')
			_.each emails, (email)->
				user = {}
				user.email = email
				unless doc.chooseOwnPassword
					user.password = doc.password

				_id = Accounts.createUser user

				if doc.sendPassword and AdminConfig.fromEmail?
					Email.send
						to: user.email
						from: AdminConfig.fromEmail
						subject: TAPi18n.__("methods.adminNewUser.emailSubject")
						html: TAPi18n.__("methods.adminNewUser.htmlTemplate", Meteor.absoluteUrl(), doc.password)

				if not doc.sendPassword
					Accounts.sendEnrollmentEmail _id

	adminUpdateUser: (modifier,_id)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			this.unblock()
			result = Meteor.users.update {_id:_id}, modifier
			return result

	adminSendResetPasswordEmail: (doc)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			console.log TAPi18n.__("methods.adminSendResetPasswordEmail.passwordChange", doc._id)
			Accounts.sendResetPasswordEmail(doc._id)

	adminChangePassword: (doc)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			console.log TAPi18n.__("methods.adminChangePassword.passwordChange", doc._id)
			Accounts.setPassword(doc._id, doc.password)
			label: TAPi18n.__("methods.adminChangePassword.label")

	adminCheckAdmin: ->
		check arguments, [Match.Any]
		user = Meteor.users.findOne(_id:this.userId)
		if this.userId and !Roles.userIsInRole(this.userId, ['admin']) and (user.emails.length > 0)
			email = user.emails[0].address
			if typeof Meteor.settings.adminEmails != 'undefined'
				adminEmails = Meteor.settings.adminEmails
				if adminEmails.indexOf(email) > -1
					console.log TAPi18n.__("methods.adminCheckAdmin.addingAdminUser", email)
					Roles.addUsersToRoles this.userId, ['admin'], Roles.GLOBAL_GROUP
			else if typeof AdminConfig != 'undefined' and typeof AdminConfig.adminEmails == 'object'
				adminEmails = AdminConfig.adminEmails
				if adminEmails.indexOf(email) > -1
					console.log TAPi18n.__("methods.adminCheckAdmin.addingAdminUser", email)
					Roles.addUsersToRoles this.userId, ['admin'], Roles.GLOBAL_GROUP
			else if this.userId == Meteor.users.findOne({},{sort:{createdAt:1}})._id
				console.log TAPi18n.__("methods.adminCheckAdmin.makingFirstUserAdmin", email)
				Roles.addUsersToRoles this.userId, ['admin']

	adminAddUserToRole: (_id,role)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			Roles.addUsersToRoles _id, role, Roles.GLOBAL_GROUP

	adminRemoveUserToRole: (_id,role)->
		check arguments, [Match.Any]
		if Roles.userIsInRole this.userId, ['admin']
			Roles.removeUsersFromRoles _id, role, Roles.GLOBAL_GROUP

	adminSetCollectionSort: (collection, _sort) ->
		check arguments, [Match.Any]
		global.AdminPages[collection].set
			sort: _sort

	adminSetDashboardSkin: (_id, skin)->
		check arguments, [Match.Any]
		Meteor.users.update(_id, {adminSettings: {skin: skin}})