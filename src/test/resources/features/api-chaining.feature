@smoke
Feature: API Chaining Demo

  Background:
    * url karate.get('baseUrl')

  Scenario: Create a post and then add a comment to that specific post
    # 1. Create the Post (POST)
    Given path 'posts'
    And request { title: 'Karate Chaining', body: 'Testing is easy', userId: 1 }
    When method POST
    Then status 201

    # Now this works because post-schema.json matches the response structure
    * def postSchema = read('classpath:schemas/post-schema.json')
    And match response == postSchema

    * def newPostId = response.id
    * print 'Created Post ID:', newPostId

    # 2. Get comments for the new post (GET)
    Given path 'comments'
    And param postId = newPostId
    When method GET
    Then status 200
    * print 'Chained comments for post:', response
