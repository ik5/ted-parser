Feature: basic api
  In Order to create basic api
  I write the following tests

  Scenario Outline: parsing rss
    Given I have <address> 
    Then result class should be <RSS::Rss>
