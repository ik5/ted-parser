Feature: basic api
  In Order to create basic api
  I write the following tests

  Scenario Outline: parsing rss
    Given I have valid <address> 
    Then return class must be <RSS::Rss>


