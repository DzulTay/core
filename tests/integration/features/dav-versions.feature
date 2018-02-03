Feature: dav-versions
  Background:
    Given using api version "2"
    And using new dav path
    And user "user0" has been created
    And file "/davtest.txt" has been deleted for user "user0"
    And as user "user0"

  Scenario: Upload file and no version is available
    When user "user0" uploads file "data/davtest.txt" to "/davtest.txt" using the API
    Then the version folder of file "/davtest.txt" for user "user0" contains "0" elements

  Scenario: Upload a file twice and versions are available
    When user "user0" uploads file "data/davtest.txt" to "/davtest.txt" using the API
    And user "user0" uploads file "data/davtest.txt" to "/davtest.txt" using the API
    Then the version folder of file "/davtest.txt" for user "user0" contains "1" elements
    And the content length of file "/davtest.txt" with version index "1" for user "user0" in versions folder is "8"

  Scenario: Remove a file
    Given user "user0" has uploaded file "data/davtest.txt" to "/davtest.txt"
    And user "user0" has uploaded file "data/davtest.txt" to "/davtest.txt"
    And the version folder of file "/davtest.txt" for user "user0" contains "1" elements
    And user "user0" has deleted file "/davtest.txt"
    When user "user0" uploads file "data/davtest.txt" to "/davtest.txt" using the API
    Then the version folder of file "/davtest.txt" for user "user0" contains "0" elements

  Scenario: Restore a file and check, if the content is now in the current file
    Given user "user0" has uploaded file with content "123" to "/davtest.txt"
    And user "user0" has uploaded file with content "12345" to "/davtest.txt"
    And the version folder of file "/davtest.txt" for user "user0" contains "1" elements
    When user "user0" restores version index "1" of file "/davtest.txt" using the API
    And user "user0" downloads the file "davtest.txt" using the API
    Then the downloaded content should be "123"

  Scenario: User cannot access meta folder of a file which is owned by somebody else
    Given user "user1" has been created
    And user "user0" has uploaded file with content "123" to "/davtest.txt"
    And we save it into "FILEID"
    And as user "user1"
    When sending "PROPFIND" with exact url to "/remote.php/dav/meta/<<FILEID>>"
    Then the HTTP status code should be "404"

  Scenario: User can access meta folder of a file which is owned by somebody else but shared with that user
    Given user "user1" has been created
    And user "user0" has uploaded file with content "123" to "/davtest.txt"
    And user "user0" has uploaded file with content "456789" to "/davtest.txt"
    And we save it into "FILEID"
    And as user "user0"
    And the user has created a share with settings
      | path | /davtest.txt |
      | shareType | 0 |
      | shareWith | user1 |
      | permissions | 8 |
    When as user "user1"
    Then the version folder of fileId "<<FILEID>>" contains "1" elements