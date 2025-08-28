Feature: Create Notifications

  Scenario:
    * configure headers = { "X-API-Key": #(eventsKey) }
    #Maker(created_by) needs to be the same as the one in the latest annex
    * param created_by = 'maker_abhi@example.com'
    Given  url baseUrl+'/notifications'
    And request createNotificationsPayload
    And set createNotificationsPayload.ucp_id = ucpId
    And set createNotificationsPayload.contract_code = contractCode
    And set createNotificationsPayload.atlas_facility_id = null
    When method POST
    Then status 201
    And match $.ucp_id == ucpId
