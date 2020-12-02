/*
This software is Copyright ©️ 2020 The University of Southern California. All Rights Reserved. 
Permission to use, copy, modify, and distribute this software and its documentation for educational, research and non-profit purposes, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and subject to the full license file found in the root of this software deliverable. Permission to make commercial use of this software may be obtained by contacting:  USC Stevens Center for Innovation University of Southern California 1150 S. Olive Street, Suite 2300, Los Angeles, CA 90115, USA Email: accounting@stevens.usc.edu

The full terms of this copyright and license should always be found in the root directory of this software deliverable as "license.txt" and if these terms are not found with this software, please contact the USC Stevens Center for the full license.
*/

it('SCENARIO: teacher creates, tests, and grades a lesson', () => {
  cy.visit('/admin');

  // log in as Teacher1
  cy.get('#login-menu #login-input').clear().type('Teacher1');
  cy.get('#login-menu #login').click();

  // see empty lesson list screen
  cy.location('pathname').should('eq', '/admin/lessons'); // redirect to lessons page
  cy.get('#lessons').children().should('have.length', 0);

  // create a new lesson
  cy.get('#create-button').click();
  cy.location('pathname').should('eq', '/admin/lessons/edit'); // redirect to edit lesson page
  cy.location('search').should('eq', '?lessonId=new'); // id should be new lesson
  cy.get('#lesson-name').clear().type('Review Diode Current Flow');
  cy.get('#lesson-id').clear().type('review-diode-current-flow');
  cy.get('#lesson-creator').should('have', 'Teacher1');
  cy.get('#intro')
    .clear()
    .type('This is a warm up question on the behavior of P-N junction diodes.');
  cy.get('#question')
    .clear()
    .type(
      'With a DC input source, does current flow in the same or the opposite direction of the diode arrow?'
    );
  cy.get('#expectation-0 #edit-expectation')
    .eq(0)
    .clear()
    .type('Current flows in the same direction as the arrow.');
  cy.get('#expectation-0 #hint-0 #edit-hint')
    .clear()
    .type(
      'What is the current direction through the diode when the input signal is DC input?'
    );
  cy.get('#conclusion-0 #edit-conclusion')
    .clear()
    .type(
      'Summing up, this diode is forward biased. Positive current flows in the same direction of the arrow, from anode to cathode.'
    );
  cy.get('#save-button').click();
  cy.get('#save-exit').click();

  // see lesson list screen with the new lesson
  cy.wait(5000);
  cy.location('pathname').should('eq', '/admin/lessons'); // redirect to lessons page
  cy.get('#lessons').children().should('have.length', 1);
  cy.get('#lesson-0 #name').contains('Review Diode Current Flow');
  cy.get('#lesson-0 #creator').contains('Teacher1');

  // launch lesson
  cy.get('#lesson-0 #launch button').click();
  cy.location('pathname').should('contain', '/tutor'); // redirect to tutor
  cy.location('search').should(
    'eq',
    '?lesson=review-diode-current-flow&guest=Teacher1'
  );

  // expect tutor with intro prompts
  cy.get('#chat-msg-0').contains('Welcome to OpenTutor');
  cy.get(`#chat-msg-1`).contains(
    'This is a warm up question on the behavior of P-N junction diodes.'
  );
  cy.get(`#chat-msg-2`).contains(
    'With a DC input source, does current flow in the same or the opposite direction of the diode arrow?'
  );

  // complete lesson
  cy.get('#outlined-multiline-static').clear().type('Give me a hint please.');
  cy.get('#submit-button').click();
  cy.wait(20000);
  cy.get('#chat-msg-6').contains(
    'What is the current direction through the diode when the input signal is DC input?'
  );
  cy.get('#outlined-multiline-static')
    .clear()
    .type('Current flows in the same direction as the arrow.');
  cy.get('#submit-button').click();
  cy.get('#summary-popup');
  cy.get('#summary-targets').children().should('have.length', 1);
  cy.get('#exp-0').contains(
    'Current flows in the same direction as the arrow.'
  );
  cy.get('#chat-msg-9').contains(
    'Summing up, this diode is forward biased. Positive current flows in the same direction of the arrow, from anode to cathode.'
  );

  // see session for completed lesson
  cy.visit('/admin/sessions/');
  cy.get('#sessions').children().should('have.length', 1);
  cy.get('#session-0 #lesson').contains('Review Diode Current Flow');
  cy.get('#session-0 #instructor-grade').contains('?');
  cy.get('#session-0 #classifier-grade').contains('50');
  cy.get('#session-0 #creator').contains('Teacher1');
  cy.get('#session-0 #username').contains('Teacher1');

  // grade session
  cy.get('#session-0 #grade').click();
  cy.location('pathname').should('eq', '/admin/sessions/session'); // redirect to grade session
  cy.get('#lesson').should('contain', 'Review Diode Current Flow');
  cy.get('#username').should('contain', 'Teacher1');
  cy.get('#question').should(
    'contain',
    'With a DC input source, does current flow in the same or the opposite direction of the diode arrow?'
  );
  cy.get('#score').should('contain', 'Score: ?');
  cy.get('#response-0 #answer').should('contain', 'Give me a hint please.');
  cy.get('#response-1 #answer').should(
    'contain',
    'Current flows in the same direction as the arrow.'
  );
  cy.get('#response-0 #grade-0 #classifier-grade').should('contain', 'Bad');
  cy.get('#response-1 #grade-0 #classifier-grade').should('contain', 'Good');
  cy.get('#response-0 #grade-0 #select-grade').should('have.value', '');
  cy.get('#response-1 #grade-0 #select-grade').should('have.value', '');
  cy.get('#response-0 #grade-0 #select-grade').click();
  cy.get('#bad').click();
  cy.get('#response-1 #grade-0 #select-grade').click();
  cy.get('#good').click();
  cy.get('#score').should('contain', 'Score: 50');

  // graded session does not appear until toggling showGraded
  cy.visit('/admin/sessions/');
  cy.get('#sessions').children().should('have.length', 0);
  cy.get('#toggle-graded').click();
  cy.get('#sessions').children().should('have.length', 1);

  // deletes lesson and session
  cy.visit('/admin/lessons/');
  cy.get('#lessons').children().should('have.length', 1);
  cy.get('#lesson-0 #delete button').click();
  cy.get('#confirm-delete').click();
  cy.get('#lessons').children().should('have.length', 0);
  cy.visit('/admin/sessions/');
  cy.get('#sessions').children().should('have.length', 0);

  // logs out
  cy.get('#nav-bar #login-button').click();
  cy.get('#logout').click();
  cy.location('pathname').should('eq', '/admin/'); // redirect to home page
});
