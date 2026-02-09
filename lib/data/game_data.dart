import 'dart:math';

class GameData {
  static final Random _random = Random();

  // Truth or Dare Questions by Level
  static const Map<String, List<String>> truthQuestions = {
    'cute': [
      'What was your first impression of me?',
      'What\'s your favorite memory of us?',
      'What do you love most about our relationship?',
      'When did you first realize you had feelings for me?',
      'What\'s the sweetest thing I\'ve ever done for you?',
      'What\'s your favorite thing about my personality?',
      'What song reminds you of us?',
      'What\'s your favorite photo of us together?',
      'What makes you smile when you think of me?',
      'What\'s one thing you want us to do together?',
    ],
    'fun': [
      'If we could travel anywhere right now, where would you pick?',
      'What\'s the funniest thing that\'s happened to us?',
      'What\'s a secret talent you have that I don\'t know about?',
      'What\'s your guilty pleasure?',
      'If you could have any superpower, what would it be?',
      'What\'s the weirdest dream you\'ve had about us?',
      'What food could you eat every day for the rest of your life?',
      'What\'s your most embarrassing moment with me?',
      'If we were in a movie, what genre would it be?',
      'What\'s one thing on your bucket list?',
    ],
    'spicy': [
      'What\'s your biggest fantasy about us?',
      'What\'s the most attractive thing I do?',
      'When do you feel most attracted to me?',
      'What\'s something new you\'d like to try together?',
      'What\'s your favorite way I show you affection?',
      'What\'s the most romantic thing we\'ve done?',
      'What makes you feel most loved by me?',
      'What\'s your favorite physical feature of mine?',
      'What\'s a secret desire you have?',
      'What\'s the most passionate moment we\'ve shared?',
    ],
    'extreme': [
      'What\'s your biggest fear about our relationship?',
      'Is there anything you\'ve been afraid to tell me?',
      'What\'s one thing you wish I did more often?',
      'Have you ever had doubts about us? When?',
      'What\'s the hardest thing about being with me?',
      'What do you think our biggest challenge is?',
      'What\'s something you need from me that you\'re not getting?',
      'Where do you see us in 5 years?',
      'What\'s one thing you would change about our relationship?',
      'What\'s your deepest insecurity in our relationship?',
    ],
  };

  static const Map<String, List<String>> dareQuestions = {
    'cute': [
      'Give me a 30-second hug',
      'Tell me 3 things you love about me',
      'Do your best impression of me',
      'Sing me a love song',
      'Give me a compliment in a funny accent',
      'Draw a picture of us together',
      'Write me a short poem',
      'Dance with me for one minute',
      'Give me a hand massage',
      'Tell me your favorite thing about today',
    ],
    'fun': [
      'Do 10 jumping jacks while saying "I love you"',
      'Speak in rhymes for the next 2 minutes',
      'Let me tickle you for 30 seconds',
      'Do your best celebrity impression',
      'Make me laugh in 30 seconds',
      'Tell me a joke (it can be terrible)',
      'Do a silly dance',
      'Speak only in questions for 2 minutes',
      'Let me style your hair however I want',
      'Do your best animal impression',
    ],
    'spicy': [
      'Kiss me somewhere I choose',
      'Give me a 2-minute massage',
      'Whisper something romantic in my ear',
      'Slow dance with me',
      'Look into my eyes without laughing for 1 minute',
      'Tell me your favorite thing about my body',
      'Give me a passionate kiss',
      'Hold me close for 2 minutes without talking',
      'Trace your finger along my hand slowly',
      'Tell me what you find most attractive about me right now',
    ],
    'extreme': [
      'Share your phone gallery with me for 2 minutes',
      'Let me read your last 5 text messages',
      'Tell me something you\'ve never told anyone',
      'Show me your most embarrassing photo',
      'Let me post anything I want on your story',
      'Answer any question I ask with complete honesty',
      'Let me go through your search history',
      'Tell me your most embarrassing moment',
      'Show me your most-used app and explain why',
      'Let me send a message to anyone in your contacts',
    ],
  };

  // Love Questions
  static const List<String> loveQuestions = [
    'What does love mean to you?',
    'How do you know when you\'re truly in love?',
    'What\'s the most important thing in a relationship?',
    'How do you want to be loved?',
    'What makes you feel most connected to me?',
    'What\'s your love language?',
    'What does your ideal relationship look like?',
    'How do you show love when words aren\'t enough?',
    'What\'s the difference between loving someone and being in love?',
    'What role does trust play in love for you?',
    'How has love changed you?',
    'What\'s the bravest thing you\'ve done for love?',
    'What do you think makes love last?',
    'How do you want our love to grow?',
    'What\'s your favorite way to receive affection?',
  ];

  // Spin the Wheel Options
  static const Map<String, List<String>> wheelOptions = {
    'who_pays': [
      'You pay! 💰',
      'I pay! 💳',
      'Split it! 🤝',
      'Loser of rock-paper-scissors pays! ✊',
    ],
    'what_to_eat': [
      'Pizza 🍕',
      'Burgers 🍔',
      'Asian Food 🍜',
      'Pasta 🍝',
      'Healthy 🥗',
      'Dessert First! 🍰',
      'Cook Together 👨‍🍳',
      'Surprise Me! 🎲',
    ],
    'movie_choice': [
      'Action 💥',
      'Romance 💕',
      'Comedy 😂',
      'Horror 👻',
      'Drama 🎭',
      'Sci-Fi 🚀',
      'Documentary 📺',
      'Your Choice! 🎬',
    ],
    'date_ideas': [
      'Movie Night 🎬',
      'Cook Together 👨‍🍳',
      'Walk in Park 🌳',
      'Game Night 🎮',
      'Stargazing ✨',
      'Coffee Date ☕',
      'Home Spa 🛁',
      'Dance Party 💃',
    ],
  };

  // Daily Love Challenges
  static const List<String> dailyChallenges = [
    'Send your partner a compliment right now',
    'Give a 10-second hug',
    'Share your favorite memory together',
    'Tell them one thing you appreciate about them',
    'Send them a love song',
    'Write them a short note',
    'Plan a surprise for later',
    'Cook or order their favorite food',
    'Give them a massage',
    'Take a cute selfie together',
    'Dance together for 2 minutes',
    'Say "I love you" in a creative way',
    'Share what made you smile today',
    'Give three genuine compliments',
    'Hold hands for 5 minutes',
  ];

  // Compliments
  static const List<String> compliments = [
    'Your smile lights up my entire day',
    'I love how you make me feel safe',
    'You\'re the most beautiful person I know, inside and out',
    'I\'m so lucky to have you in my life',
    'You make everything better just by being here',
    'Your laugh is my favorite sound',
    'I love how passionate you are about things',
    'You inspire me to be a better person',
    'Your kindness is one of the things I love most about you',
    'I love how you always know how to make me smile',
    'You\'re my favorite person to talk to',
    'I admire your strength and resilience',
    'You have the most beautiful heart',
    'I love how you see the world',
    'You make me believe in love',
  ];

  // Finish the Sentence
  static const List<String> sentenceStarters = [
    'We are strongest when we ___',
    'I love you most when you ___',
    'Our relationship is special because ___',
    'Together we can ___',
    'You make me feel ___ every day',
    'The best thing about us is ___',
    'I knew you were special when ___',
    'Our love is like ___',
    'With you, I can ___',
    'We are perfect together because ___',
  ];

  // Emoji Guess Challenges
  static const Map<String, String> emojiChallenges = {
    '❤️🔥': 'Hot love / Passionate',
    '🌙✨': 'Magical night / Dreamy',
    '☕🥐': 'Breakfast date',
    '🎬🍿': 'Movie night',
    '🌹💋': 'Romance / Kiss',
    '🎵💃': 'Dancing / Party',
    '🏖️☀️': 'Beach day',
    '🍕🍷': 'Dinner date',
    '⭐💫': 'Stargazing',
    '🎁💝': 'Gift / Surprise',
  };

  // Act It Out Prompts
  static const List<String> actingPrompts = [
    'Act like you\'re meeting me for the first time',
    'Pretend you\'re a waiter at a fancy restaurant',
    'Act like you just won the lottery',
    'Pretend you\'re teaching me something you\'re expert at',
    'Act like you\'re a news reporter announcing our relationship',
    'Pretend you\'re proposing (even if already together)',
    'Act like you\'re from a different era',
    'Pretend you\'re a motivational speaker',
    'Act like you\'re in a romantic movie scene',
    'Pretend you\'re a tour guide showing me around',
  ];

  // Couple Quotes (50 quotes)
  static const List<String> coupleQuotes = [
    'In all the world, there is no heart for me like yours.',
    'To the world you may be one person, but to me you are the world.',
    'I love being yours and knowing you are mine.',
    'Home is wherever I am with you.',
    'Every love story is beautiful, but ours is my favorite.',
    'You are my today and all of my tomorrows.',
    'Loved you yesterday, love you still, always have, always will.',
    'I choose you. And I’ll choose you over and over and over.',
    'You’re my favorite place to go when my mind searches for peace.',
    'If I know what love is, it is because of you.',
    'My heart is and always will be yours.',
    'Together is a beautiful place to be.',
    'You are my heart, my life, my one and only thought.',
    'Growing old with you is the best part of my day.',
    'You make me want to be a better person.',
    'I love you for all that you are and all that you yet to be.',
    'I fell in love with you because of a million things you never knew you were doing.',
    'Your love is like the lamp in the window that guides me home.',
    'Everything I never knew I always wanted.',
    'You are the best thing that ever happened to me.',
    'Meeting you was like listening to a song for the first time and knowing it would be my favorite.',
    'You are the icing on my cake and the sun in my sky.',
    'I love you more than words can say.',
    'You are my soulmate and my best friend.',
    'Life is better with you by my side.',
    'I love the way we are together.',
    'You are the reason I smile every day.',
    'My favorite fairytale is our love story.',
    'I would follow you to the ends of the earth.',
    'You are my greatest adventure.',
    'I love you to the moon and back.',
    'You are my anchor in this crazy life.',
    'With you, I am home.',
    'I love your laugh and your beautiful heart.',
    'You are the person I want to spend forever with.',
    'No matter where we go, as long as we’re together, I’m happy.',
    'You are everything I’ve ever dreamed of.',
    'Thank you for being you and for loving me.',
    'Our love is a journey, starting at forever and ending at never.',
    'You are the piece of me I didn’t know was missing.',
    'I love you more than coffee, but please don’t make me prove it.',
    'You are the only person I want to annoy for the rest of my life.',
    'I love you even when I’m hungry.',
    'Being with you is the easiest thing I’ve ever done.',
    'You are my favorite notification.',
    'I love you for your sense of humor and your kind soul.',
    'You are my first thought in the morning and my last thought at night.',
    'Thank you for making my life so much brighter.',
    'I love our late-night conversations and our early morning cuddles.',
    'You are the love of my life.',
  ];

  // Helper methods to get random items
  static String getRandomTruth(String level) {
    final questions = truthQuestions[level] ?? truthQuestions['cute']!;
    return questions[_random.nextInt(questions.length)];
  }

  static String getRandomDare(String level) {
    final dares = dareQuestions[level] ?? dareQuestions['cute']!;
    return dares[_random.nextInt(dares.length)];
  }

  static String getRandomLoveQuestion() {
    return loveQuestions[_random.nextInt(loveQuestions.length)];
  }

  static String getRandomChallenge() {
    return dailyChallenges[_random.nextInt(dailyChallenges.length)];
  }

  static String getRandomCompliment() {
    return compliments[_random.nextInt(compliments.length)];
  }

  static String getRandomQuote() {
    return coupleQuotes[_random.nextInt(coupleQuotes.length)];
  }

  static String getRandomSentenceStarter() {
    return sentenceStarters[_random.nextInt(sentenceStarters.length)];
  }

  static String getRandomActingPrompt() {
    return actingPrompts[_random.nextInt(actingPrompts.length)];
  }

  static List<String> getWheelOptions(String category) {
    return wheelOptions[category] ?? [];
  }

  static MapEntry<String, String> getRandomEmojiChallenge() {
    final entries = emojiChallenges.entries.toList();
    return entries[_random.nextInt(entries.length)];
  }
}
