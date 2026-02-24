@regression
Feature: Delete a post

  Background:
    * url karate.get('baseUrl')

  Scenario: Delete post ID 1
    Given path 'posts', 1
    When method DELETE
    Then status 200
    * print 'Deleted post ID 1 successfully'
