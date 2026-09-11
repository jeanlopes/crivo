# Example — replace with your domain. Feature files are human-owned (P06).
Feature: Add a leg to an itinerary
  Scenario: Leg overlapping an existing leg on the same day is rejected
    Given an itinerary with leg "FRA→BER" on 2026-12-12 from 08:00 to 12:00
    When the user adds leg "FRA→MUC" on 2026-12-12 from 10:00 to 14:00
    Then the system rejects with reason "time_conflict"
    And the itinerary still has 1 leg

  Scenario: Non-overlapping leg is accepted
    Given an itinerary with leg "FRA→BER" on 2026-12-12 from 08:00 to 12:00
    When the user adds leg "BER→MUC" on 2026-12-12 from 13:00 to 16:00
    Then the itinerary has 2 legs
