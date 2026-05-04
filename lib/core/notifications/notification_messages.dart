/// A curated list of creative, friendly, modern re-engagement notification
/// messages for the Tunisian Trip Planner app.
///
/// Categories: comeback, discovery, curiosity, offers, motivation, travel-specific.
class NotificationMessages {
  NotificationMessages._();

  static const List<NotificationMessage> all = [
    // ── Comeback ──────────────────────────────────────────────────────────
    NotificationMessage(
      title: 'We miss you!',
      body: 'Tunisia has so much more to offer. Come back and explore!',
    ),
    NotificationMessage(
      title: 'We have not seen you in a while',
      body: 'Your next adventure is waiting - open TuniWays!',
    ),
    NotificationMessage(
      title: 'Hey traveler!',
      body: 'It has been a minute. Ready to plan your next getaway?',
    ),
    NotificationMessage(
      title: 'Your wanderlust is calling',
      body: 'Open TuniWays and let the journey begin.',
    ),
    NotificationMessage(
      title: 'Long time no see!',
      body: 'New destinations and deals are waiting for you.',
    ),

    // ── Discovery ─────────────────────────────────────────────────────────
    NotificationMessage(
      title: 'Discover new places near you',
      body: 'Hidden gems in Tunisia you might have missed.',
    ),
    NotificationMessage(
      title: 'Something new is waiting for you',
      body: 'Fresh stays and agencies just got added. Take a look!',
    ),
    NotificationMessage(
      title: 'Explore the unseen',
      body: 'Ancient ruins, modern vibes - Tunisia has it all.',
    ),
    NotificationMessage(
      title: 'New hotels just dropped',
      body: 'Check out the latest accommodations in your favorite cities.',
    ),
    NotificationMessage(
      title: 'Coastal escapes are trending',
      body: 'Discover beautiful beachfront stays along the Mediterranean.',
    ),

    // ── Curiosity ─────────────────────────────────────────────────────────
    NotificationMessage(
      title: 'Did you know?',
      body: 'Tunisia has 8 UNESCO World Heritage Sites. Explore them all!',
    ),
    NotificationMessage(
      title: 'Guess what is popular right now',
      body: 'See the top-rated places other travelers are loving.',
    ),
    NotificationMessage(
      title: 'A surprise awaits you',
      body: 'Open TuniWays to see what is new this week.',
    ),
    NotificationMessage(
      title: 'Your trip wishlist misses you',
      body: 'Those saved places are still waiting to be booked!',
    ),
    NotificationMessage(
      title: 'Travel inspiration incoming',
      body: '3 trending destinations you should check out today.',
    ),

    // ── Offers & Value ────────────────────────────────────────────────────
    NotificationMessage(
      title: 'Great deals nearby',
      body: 'Affordable stays and rides - do not miss out!',
    ),
    NotificationMessage(
      title: 'Prices just dropped',
      body: 'Some of your favorite hotels now have lower rates.',
    ),
    NotificationMessage(
      title: 'Weekend getaway?',
      body: 'Find last-minute deals for the perfect escape.',
    ),
    NotificationMessage(
      title: 'Budget-friendly adventures',
      body: 'Great trips do not have to break the bank. Explore now!',
    ),
    NotificationMessage(
      title: 'Exclusive picks for you',
      body: 'We curated the best options based on your preferences.',
    ),

    // ── Motivation ────────────────────────────────────────────────────────
    NotificationMessage(
      title: 'Life is short, travel more',
      body: 'Start planning your next Tunisian adventure today.',
    ),
    NotificationMessage(
      title: 'Do not just dream it, book it',
      body: 'Your perfect trip is just a few taps away.',
    ),
    NotificationMessage(
      title: 'Adventure is out there',
      body: 'The Sahara, Sidi Bou Said, Djerba - where will you go?',
    ),
    NotificationMessage(
      title: 'Make memories, not excuses',
      body: 'Plan a trip that future you will thank you for.',
    ),
    NotificationMessage(
      title: 'Your next chapter starts here',
      body: 'Every great story includes a great trip.',
    ),

    // ── Travel-specific Tunisia ───────────────────────────────────────────
    NotificationMessage(
      title: 'Sidi Bou Said is calling',
      body: 'Blue doors, white walls, and endless charm await you.',
    ),
    NotificationMessage(
      title: 'Sahara sunsets are unmatched',
      body: 'Book a desert experience you will never forget.',
    ),
    NotificationMessage(
      title: 'Djerba dreams',
      body: 'Island vibes and warm hospitality - plan your visit!',
    ),
    NotificationMessage(
      title: 'Carthage awaits, explorer',
      body: 'Walk through history at one of the oldest cities in the world.',
    ),
    NotificationMessage(
      title: 'Mediterranean mood',
      body: 'Crystal clear waters and fresh seafood - your escape awaits.',
    ),
    NotificationMessage(
      title: 'Tunisian flavors',
      body: 'Discover restaurants and local food experiences near you.',
    ),
  ];
}

/// A single notification message with a title and body.
class NotificationMessage {
  final String title;
  final String body;

  const NotificationMessage({
    required this.title,
    required this.body,
  });
}
