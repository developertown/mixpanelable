Mixpanelable
============
Mixpanelable makes it simple to track Mixpanel events in your Rails backend. While there are other gems (e.g. [mixpanel] and [mixpanel_client]) that provide an api to Mixpanel, Mixpanelable addresses several problems for the Rails developer that are ignored by existing solutions:

- **Event tracking in models (or anywhere).** I find observers a comfortable place to track events. Many events can be tied to model callbacks, such as after_create. Furthermore, some events can only be tracked from models or observers or would otherwise be difficult to track in the controller.
- **More powerful funnels through more flexible distinct id's.** Sometimes events in funnels don't tie to a user (the "distinct id"). Mixpanel is built to track events initiated by a user, but what if we want to create a funnel from events such as 'Invoice Sent' and 'Invoice Paid'? To do so requires tying the events to the invoice, not the user. Mixpanelable's `track_event_for` method lets you tie events to any ActiveRecord.
- **Anonymous user tracking.** Need to track events that aren't tied to anyone or anything yet? No problem. Mixpanelable automatically assigns and stores within a cookie a UUID for all visitors.

What is Mixpanel and why should I use it?
-----------------------------------------
Mixpanel provides an api to capture actions taken by users and visualize the resulting data. I've used Mixpanel for a variety of reasons beyond traditional marketing funnels and retention reports. For example, features can be profiled to track performance over time. Funnels can represent a workflow in your system, such as invoice generation and payment.

If you haven't used Mixpanel before, I suggest looking through their [marketing site] and [features guide] for developers.

Installation
------------
1. Add `gem 'mixpanelable'` to your Gemfile.
2. Run `bundle install`
3. In an initializer, add `Mixpanelable::Config.token = your_mixpanel_token_here`. You may want to have a different token (i.e. Mixpanel project) for development and production.
4. Restart your server and start tracking!

Resque Dependency
-----------------
To fire events to Mixpanel asynchronously, Mixpanelable currently depends on Resque. If Resque is not set up in your app, then Mixpanelable won't work and will throw exceptions. This is high on the priority list of things to fix!

Tracking Events
---------------
Mixpanelable's api is simple and without surprises.

### Tracking an event tied to a user or visitor

Anywhere in your code (typically a controller, model or observer):

````
track_event('Event Name', {
  'A property' => 'Property value',
  'Another property' => 'Another value'
})
````

Mixpanelable will automatically detect whether the current_user method in your controller is nil. If so, the event is tied to the visitor's unique uuid, and (assuming cookies are enabled) all future events from the visitor will be tied to the unique uuid.

Otherwise, the event will be tied to the logged-in user.

### Tracking an event tied to a record

````
track_event_for(record, 'Event Name', {
  'A property' => 'Property value',
  'Another property' => 'Another value'
})
````

The event will be tied to the record's type (i.e. class name) and id. This is *important* if you want to create funnels that can't be tied back to a user (see examples below). Get creative!

### Tracking an event tied to the request

````
track_event_for_request('Event Name', {
  'A property' => 'Property value'
})
````

Mixpanelable will tie the event to a unique uuid associated with the request. See Examples for potential use cases.

Examples
--------

### Events for a basic marketing funnel

You may want to track that someone has visited your landing page.

````
class HomeController < ApplicationController
  def index
    track_event('Visitor: View Landing Page')
  end
end
````

Bonus: if you A/B test, you can track the version of the page:

````
track_event('Visitor: View Landing Page', {
  'Version': 'A'
})
````

Later you can track that the user has registered.

````
class User < ActiveRecord::Base
  # I would prefer to place this in an observer, where it doesn't obscure my model code.
  # But this is a simple example.
  after_create :track_create

  def track_create
    # This will be tied to an anonymous visitor because no current user exists yet.
    track_event('Visitor: Signed Up')

    # If we want to create funnels for a new user's workflow, then we'll need to capture
    # another sign up event tied to the user.
    track_event_for(self, 'User: Signed Up')
  end
end
````

### Events for non-user-related funnels.

Let's say I have an app that lets users create invoices and get paid online. I want to know how often invoices are received and paid so I know when I'm improving the workflow.

````
class Invoice < ActiveRecord::Base
  after_update :track_sent, if: :just_sent?
  after_update :track_received, if: :just_received?
  after_update :track_paid, if: :just_paid?

  def just_sent?
    # return true if just sent
  end

  def just_paid?
    # return true if just paid
  end

  def track_sent
    track_event_for(self, 'Invoice: Sent')
  end

  def track_received
    track_event_for(self, 'Invoice: Received')
  end

  def track_paid
    track_event_for(self, 'Invoice: Paid')
  end
````

Back in Mixpanel, a funnel can be created that tracks the conversion from Sent -> Received -> Paid. I can then answer questions like, how often are invoices being ignored by customers? What percentage of invoices are getting paid? And this data can be tracked over time to see improvements or regressions.

Note that if these events are tied to the user who performed the action (instead of the invoice), then we wouldn't be able to create the funnel.

### Frequency of events with respect to requests

Sometimes it's useful to see the frequency at which an event occurs in proportion to the number of requests. Mixpanelable makes this possible through `track_event_for_request`.

Recently, I wanted to create a funnel that showed the proportion of cache writes to page hits for a list of events. In my view, I wrote

````
<% track_event_for_request('Events List Hit') %>

<% cache(@user) do %>
  <% track_event_for_request('Events List Cache Write') %>
  <% # My events html... %>
<% end %>
````

Simple. Mixpanel will receive one or both events depending on whether the cache has expired when hit. Then, I can create a funnel to track the proportion over time.

Todos
-----

* Don't rely on curl for api calls
* Provide out-of-the-box support when Resque isn't available (potentially using Delayed Job)
* Sidekiq support

[mixpanel]: https://github.com/zevarito/mixpanel
[mixpanel_client]: https://github.com/keolo/mixpanel_client

[marketing site]: http//www.mixpanel.com
[features guide]: https://mixpanel.com/docs/getting-started/learn-about-the-features