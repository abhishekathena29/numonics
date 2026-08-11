import 'package:flutter/material.dart';
import '../models/challenge.dart';

/// Local seed catalog of daily challenges. Keeping the questions on-device
/// means the quiz works offline; Mathy (Groq) handles free-form help.
const List<Challenge> kChallenges = [
  Challenge(
    id: 'basic_arithmetic',
    title: 'Basic Arithmetic',
    difficulty: Difficulty.beginner,
    icon: Icons.calculate_outlined,
    questions: [
      Question(
        prompt: 'What is 24 + 38?',
        options: ['52', '62', '58', '64'],
        correctIndex: 1,
        explanation:
            'Add the ones: 4 + 8 = 12 (write 2, carry 1). Add the tens: '
            '2 + 3 = 5, plus the carried 1 = 6. So 24 + 38 = 62.',
      ),
      Question(
        prompt: 'What is 15 × 6?',
        options: ['80', '90', '96', '85'],
        correctIndex: 1,
        explanation:
            '15 × 6 = (10 × 6) + (5 × 6) = 60 + 30 = 90.',
      ),
      Question(
        prompt: 'What is 144 ÷ 12?',
        options: ['11', '12', '14', '10'],
        correctIndex: 1,
        explanation: '12 × 12 = 144, so 144 ÷ 12 = 12.',
      ),
      Question(
        prompt: 'What is 100 − 47?',
        options: ['53', '63', '57', '43'],
        correctIndex: 0,
        explanation: '100 − 47: 100 − 40 = 60, then 60 − 7 = 53.',
      ),
      Question(
        prompt: 'What is 7 × 8 + 4?',
        options: ['56', '60', '64', '58'],
        correctIndex: 1,
        explanation:
            'Multiply first (order of operations): 7 × 8 = 56, then add 4 = 60.',
      ),
    ],
  ),
  Challenge(
    id: 'number_patterns',
    title: 'Number Patterns',
    difficulty: Difficulty.beginner,
    icon: Icons.tag,
    questions: [
      Question(
        prompt: 'What comes next? 2, 4, 8, 16, ...',
        options: ['20', '24', '32', '18'],
        correctIndex: 2,
        explanation: 'Each term doubles the previous one, so 16 × 2 = 32.',
      ),
      Question(
        prompt: 'What comes next? 3, 6, 9, 12, ...',
        options: ['14', '15', '16', '18'],
        correctIndex: 1,
        explanation: 'This counts up by 3 each step: 12 + 3 = 15.',
      ),
      Question(
        prompt: 'Find the missing number: 1, 1, 2, 3, 5, __, 13',
        options: ['7', '8', '9', '6'],
        correctIndex: 1,
        explanation:
            'This is the Fibonacci sequence — each term is the sum of the two '
            'before it: 3 + 5 = 8.',
      ),
      Question(
        prompt: 'What comes next? 100, 90, 81, 73, ...',
        options: ['66', '64', '68', '65'],
        correctIndex: 0,
        explanation:
            'The gap shrinks by 1 each time: −10, −9, −8, then −7. '
            '73 − 7 = 66.',
      ),
    ],
  ),
  Challenge(
    id: 'simple_fractions',
    title: 'Simple Fractions',
    difficulty: Difficulty.beginner,
    icon: Icons.pie_chart_outline,
    questions: [
      Question(
        prompt: 'What is 1/2 + 1/4?',
        options: ['2/6', '3/4', '1/3', '2/4'],
        correctIndex: 1,
        explanation:
            'Give them the same denominator: 1/2 = 2/4. Then 2/4 + 1/4 = 3/4.',
      ),
      Question(
        prompt: 'Simplify 6/8.',
        options: ['2/3', '3/4', '4/5', '1/2'],
        correctIndex: 1,
        explanation:
            'Divide top and bottom by their common factor 2: 6/8 = 3/4.',
      ),
      Question(
        prompt: 'What is 2/3 of 9?',
        options: ['5', '6', '7', '4'],
        correctIndex: 1,
        explanation: '9 ÷ 3 = 3, and 3 × 2 = 6. So 2/3 of 9 is 6.',
      ),
    ],
  ),
  Challenge(
    id: 'algebra_basics',
    title: 'Algebra Basics',
    difficulty: Difficulty.intermediate,
    icon: Icons.functions,
    questions: [
      Question(
        prompt: 'Solve for x: x + 7 = 12',
        options: ['4', '5', '6', '19'],
        correctIndex: 1,
        explanation:
            'Subtract 7 from both sides: x = 12 − 7 = 5.',
      ),
      Question(
        prompt: 'Solve for x: 3x = 21',
        options: ['6', '7', '8', '9'],
        correctIndex: 1,
        explanation: 'Divide both sides by 3: x = 21 ÷ 3 = 7.',
      ),
      Question(
        prompt: 'Expand (a + b)² when a = 2, b = 3.',
        options: ['13', '25', '20', '36'],
        correctIndex: 1,
        explanation:
            '(a + b)² = (2 + 3)² = 5² = 25. Equivalently a² + 2ab + b² = '
            '4 + 12 + 9 = 25.',
      ),
      Question(
        prompt: 'Solve for x: 2x − 4 = 10',
        options: ['6', '7', '8', '5'],
        correctIndex: 1,
        explanation:
            'Add 4 to both sides: 2x = 14. Divide by 2: x = 7.',
      ),
    ],
  ),
  Challenge(
    id: 'geometry',
    title: 'Geometry & Trig',
    difficulty: Difficulty.intermediate,
    icon: Icons.change_history,
    questions: [
      Question(
        prompt:
            'A rabbit spots an eagle at an angle of elevation of 60°. The '
            'distance between them (the hypotenuse) is 18 m. How high is the '
            'eagle above the ground?',
        options: ['13.59 m', '15.59 m', '18.59 m', '21.59 m'],
        correctIndex: 1,
        diagram: Diagram.rightTriangle,
        explanation:
            'Use sin A = opposite / hypotenuse. The height is the opposite '
            'side, so sin 60° = x / 18. Since sin 60° = √3/2, '
            'x = (√3/2) × 18 = 9√3 ≈ 15.59 m.',
      ),
      Question(
        prompt: 'What is the sum of the interior angles of a triangle?',
        options: ['90°', '180°', '270°', '360°'],
        correctIndex: 1,
        explanation:
            'The interior angles of any triangle always add up to 180°.',
      ),
      Question(
        prompt: 'A right triangle has legs 3 and 4. What is the hypotenuse?',
        options: ['5', '6', '7', '12'],
        correctIndex: 0,
        explanation:
            'By the Pythagorean theorem: c² = 3² + 4² = 9 + 16 = 25, so c = 5.',
      ),
    ],
  ),
];
