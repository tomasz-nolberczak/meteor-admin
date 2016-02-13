getUserLanguage = function () {
  // Put here the logic for determining the user language
  console.log('pl')
  return "pl";
};

Meteor.startup(function () {
  TAPi18n.setLanguage(getUserLanguage());
});