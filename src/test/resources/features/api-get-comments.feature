@regression
Feature: Get comments for a specific post

  Background:
    # Use the base URL from karate-config.js
    * url karate.get('baseUrl')

  Scenario: Retrieve comments for post ID 1
    Given path 'posts', 1, 'comments'
    When method GET
    Then status 200
    # Optional: Basic validation of response structure
    * match each response[*] contains { postId: 1 }
    * print 'Retrieved comments:', response
