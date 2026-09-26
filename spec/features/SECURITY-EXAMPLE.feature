# Example abuse scenarios (P11). Feature files are human-owned (P06).
# Tag every scenario @security plus the SEC- control it exercises; the `security` layer
# checks that each triggered domain has at least one, and `e2e` runs them against real dependencies.
Feature: Abuse cases for an app users reach already signed in

  Background:
    Given tenant "acme" with user "ana" and tenant "globex" with user "gil"

  @security @SEC-050
  Scenario: A used handoff code cannot be replayed
    Given "ana" arrives from the origin system with a valid handoff code
    And the app has exchanged that code for a session
    When the same code is presented again from another browser
    Then the response is 401
    And no session cookie is set

  @security @SEC-050
  Scenario: A handoff code minted for another application is rejected
    Given a valid handoff code whose audience is "other-app"
    When it is presented to the landing route
    Then the response is 401

  @security @SEC-050 @SEC-022
  Scenario: The handoff code does not leak from the landing page
    Given "ana" arrives from the origin system with a valid handoff code
    When the landing page has finished loading
    Then the address bar no longer contains the code
    And no request made by the page carries the code in its URL or Referer header

  @security @SEC-027
  Scenario Outline: The landing route does not redirect off-site
    When a visitor opens the landing route with next "<target>"
    Then the browser stays on the app's origin

    Examples:
      | target                   |
      | https://evil.example     |
      | //evil.example           |
      | /\evil.example           |
      | javascript:alert(1)      |

  @security @SEC-058 @SEC-062
  Scenario: A user cannot read another tenant's record by identifier
    Given "gil" owns invoice "INV-9"
    When "ana" requests invoice "INV-9" by its identifier
    Then the response is 404
    And the response body does not contain "INV-9"

  @security @SEC-009
  Scenario: Privileged fields in a profile update are ignored
    When "ana" updates her profile with name "Ana" and role "admin"
    Then her name is "Ana"
    And her role is unchanged

  @security @SEC-018
  Scenario: Script in a comment does not execute
    When "ana" posts the comment "<img src=x onerror=window.__pwned=1>"
    And "gil" opens the page that shows it
    Then the browser global "__pwned" is undefined

  @security @SEC-040 @SEC-081
  Scenario: Repeated failed logins are throttled
    When 20 logins for "ana" fail within one minute
    Then the next login attempt receives 429 or a challenge
    And a correct login after the throttle window succeeds

  @security @SEC-126
  Scenario: A single-use coupon applied concurrently takes effect once
    Given "ana" holds single-use coupon "WELCOME10"
    When 20 checkout requests with "WELCOME10" arrive at the same time
    Then exactly 1 order has the discount applied
