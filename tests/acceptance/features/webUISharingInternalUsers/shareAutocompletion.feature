@webUI @insulated @disablePreviews @TestAlsoOnExternalUserBackend
Feature: Autocompletion of share-with names
  As a user
  I want to share files, with minimal typing, to the right people or groups
  So that I can efficiently share my files with other users or groups

  Background:
    # Users that are in the special known users already
    Given these users have been created with default attributes but not initialized:
      | username    |
      | user1       |
      | user3       |
      | usergrp     |
      | regularuser |
    # Some extra users to make the share autocompletion interesting
    Given these users have been created but not initialized:
      | username  | password  | displayname     | email          |
      | two       | %regular% | User Two        | u2@oc.com.np   |
      | u444      | %regular% | Four            | u3@oc.com.np   |
      | five      | %regular% | User Group      | five@oc.com.np |
      | usersmith | %regular% | John Finn Smith | js@oc.com.np   |
    And these groups have been created:
      | groupname     |
      | finance1      |
      | finance2      |
      | finance3      |
      | users-finance |
      | other         |

  @skipOnLDAP @user_ldap-issue-175
  @smokeTest
  Scenario: autocompletion of regular existing users
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "us" in the share-with-field
    Then all users and groups that contain the string "us" in their name should be listed in the autocomplete list on the webUI
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  @smokeTest
  Scenario: autocompletion of regular existing groups
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "fi" in the share-with-field
    Then all users and groups that contain the string "fi" in their name should be listed in the autocomplete list on the webUI
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "other" should not be listed in the autocomplete list on the webUI

  Scenario: autocompletion for a pattern that does not match any user or group
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "doesnotexist" in the share-with-field
    Then a tooltip with the text "No users or groups found for doesnotexist" should be shown near the share-with-field on the webUI
    And the autocomplete list should not be displayed on the webUI

  @skipOnLDAP
  Scenario: autocomplete short user/display names when completely typed
    Given the administrator has set the minimum characters for sharing autocomplete to "4"
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And these users have been created but not initialized:
      | username | password | displayname | email        |
      | use      | %alt1%   | Use         | uz@oc.com.np |
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "Use" in the share-with-field
    Then only "Use" should be listed in the autocomplete list on the webUI
    And user "User Two" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocomplete short group names when completely typed
    Given the administrator has set the minimum characters for sharing autocomplete to "3"
    And these groups have been created:
      | groupname |
      | fi        |
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "fi" in the share-with-field
    Then only "fi (group)" should be listed in the autocomplete list on the webUI
    And user "finance1" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion when minimum characters is the default (2) and not enough characters are typed
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "u" in the share-with-field
    Then a tooltip with the text "No users or groups found for u. Please enter at least 2 characters for suggestions" should be shown near the share-with-field on the webUI
    And the autocomplete list should not be displayed on the webUI

  @skipOnLDAP
  Scenario: autocompletion when minimum characters is increased and not enough characters are typed
    Given the administrator has set the minimum characters for sharing autocomplete to "4"
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "use" in the share-with-field
    Then a tooltip with the text "No users or groups found for use. Please enter at least 4 characters for suggestions" should be shown near the share-with-field on the webUI
    And the autocomplete list should not be displayed on the webUI

  @skipOnLDAP
  Scenario: autocompletion when increasing the minimum characters for sharing autocomplete
    Given the administrator has set the minimum characters for sharing autocomplete to "3"
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "use" in the share-with-field
    Then all users and groups that contain the string "use" in their name should be listed in the autocomplete list on the webUI
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP @user_ldap-issue-175
  Scenario: autocompletion of a pattern that matches regular existing users but also a user with whom the item is already shared (folder)
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has shared folder "simple-folder" with user "User One" using the webUI
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "user" in the share-with-field
    Then all users and groups that contain the string "user" in their name should be listed in the autocomplete list on the webUI except user "User One"
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP @user_ldap-issue-175
  Scenario: autocompletion of a pattern that matches regular existing users but also a user with whom the item is already shared (file)
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has shared file "data.zip" with user "User Grp" using the webUI
    And the user has opened the share dialog for file "data.zip"
    When the user types "user" in the share-with-field
    Then all users and groups that contain the string "user" in their name should be listed in the autocomplete list on the webUI except user "User Grp"
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern that matches regular existing groups but also a group with whom the item is already shared (folder)
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user shares folder "simple-folder" with group "finance1" using the webUI
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "fi" in the share-with-field
    Then all users and groups that contain the string "fi" in their name should be listed in the autocomplete list on the webUI except group "finance1"
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern that matches regular existing groups but also a group with whom the item is already shared (file)
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user shares file "data.zip" with group "finance1" using the webUI
    And the user has opened the share dialog for file "data.zip"
    When the user types "fi" in the share-with-field
    Then all users and groups that contain the string "fi" in their name should be listed in the autocomplete list on the webUI except group "finance1"
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern where the name of existing users contains the pattern somewhere in the middle
    Given user "user1" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "se" in the share-with-field
    Then all users and groups that contain the string "se" in their name should be listed in the autocomplete list on the webUI
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "Four" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern where the name of existing users contains the pattern at the end
    Given user "usergrp" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "r3" in the share-with-field
    Then all users and groups that contain the string "r3" in their name should be listed in the autocomplete list on the webUI
    And the users own name should not be listed in the autocomplete list on the webUI
    And user "User One" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern where the name of existing group contains the pattern somewhere in the middle
    Given user "user1" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "anc" in the share-with-field
    Then all users and groups that contain the string "finance" in their name should be listed in the autocomplete list on the webUI
    But group "other" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern where the name of existing group contains the pattern at the end
    Given user "user1" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "ce2" in the share-with-field
    Then all users and groups that contain the string "finance2" in their name should be listed in the autocomplete list on the webUI
    But group "finance1" should not be listed in the autocomplete list on the webUI
    But group "finance3" should not be listed in the autocomplete list on the webUI
    But group "users-finance" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern where the name of existing group contains the pattern somewhere in the middle but group medial search is disabled
    Given user "user1" has logged in using the webUI
    And the administrator has added system config key "groups.enable_medial_search" with value "false" and type "boolean"
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "anc" in the share-with-field
    Then all users and groups that contain the string "finance" in their name should be listed in the autocomplete list on the webUI
    But group "other" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: allow user to disable autocomplete in sharing dialog
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the personal sharing settings page
    When the user disables allow finding you via autocomplete in share dialog
    And the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder"
    And the user types "reg" in the share-with-field
    Then user "Regular User" should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: user disables autocomplete in sharing dialog but the sharer types full username
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the personal sharing settings page
    When the user disables allow finding you via autocomplete in share dialog
    And the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder"
    And the user types "regularuser" in the share-with-field
    Then user "Regular User" should be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: user disables autocomplete in sharing dialog but the sharer types full display name
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the personal sharing settings page
    When the user disables allow finding you via autocomplete in share dialog
    And the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder"
    And the user types "Regular User" in the share-with-field
    Then user "Regular User" should be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: allow user to enable autocomplete in sharing dialog
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the personal sharing settings page
    When the user enables allow finding you via autocomplete in share dialog
    And the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder"
    And the user types "reg" in the share-with-field
    Then user "Regular User" should be listed in the autocomplete list on the webUI
    And the users own name should not be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of a pattern when admin disables username autocompletion in share dialog
    Given parameter "shareapi_allow_share_dialog_user_enumeration" of app "core" has been set to "no"
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "user" in the share-with-field
    Then a tooltip with the text "No users or groups found for user" should be shown near the share-with-field on the webUI
    And the autocomplete list should not be displayed on the webUI

  @skipOnLDAP
  Scenario: admin disables share dialog user enumeration
    Given parameter "shareapi_allow_share_dialog_user_enumeration" of app "core" has been set to "no"
    And user "regularuser" has logged in using the webUI
    When the user browses to the personal sharing settings page
    Then allow finding you via autocomplete checkbox should not be displayed on the personal sharing settings page

  @skipOnLDAP
  Scenario: admin disables share dialog user enumeration and types full user name of user in sharing dialog
    Given parameter "shareapi_allow_share_dialog_user_enumeration" of app "core" has been set to "no"
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "user1" in the share-with-field
    Then user "User One" should be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: admin disables share dialog user enumeration and types full display name of user in sharing dialog
    Given parameter "shareapi_allow_share_dialog_user_enumeration" of app "core" has been set to "no"
    And user "regularuser" has logged in using the webUI
    And the user has browsed to the files page
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "User One" in the share-with-field
    Then user "User One" should be listed in the autocomplete list on the webUI

  @skipOnLDAP
  Scenario: autocompletion of pattern when user disables and then enables autocompletion in sharing dialog
    Given user "regularuser" has logged in using the webUI
    And the user has browsed to the personal sharing settings page
    When the user disables allow finding you via autocomplete in share dialog
    And the user enables allow finding you via autocomplete in share dialog
    And the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder"
    And the user types "reg" in the share-with-field
    Then user "Regular User" should be listed in the autocomplete list on the webUI
