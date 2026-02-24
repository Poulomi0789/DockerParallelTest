@regression
Feature: Update a post

  Background:
    * url karate.get('baseUrl')

  Scenario: Update the title and body of post ID 1
    Given path 'posts', 1
    And request { title: 'Updated Title', body: 'Updated body content', userId: 1 }
    When method PUT
    Then status 200
    # Optional: Validate the updated fields
    * match response.title == 'Updated Title'
    * match response.body == 'Updated body content'
    * print 'Updated Post Response:', response
