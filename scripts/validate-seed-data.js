const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '..', 'assets', 'data', 'emsile_seed.json');
const validCategories = new Set(['mazi', 'muzari']);
const validVoices = new Set(['malum', 'mechul']);

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function assertString(value, field) {
  assert(typeof value === 'string' && value.trim().length > 0, `${field} must be a non-empty string`);
}

function main() {
  const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

  assert(Array.isArray(data.lessons), 'lessons must be an array');
  assert(Array.isArray(data.forms), 'forms must be an array');
  assert(Array.isArray(data.practiceQuestions), 'practiceQuestions must be an array');

  data.lessons.forEach((lesson, index) => {
    assert(Number.isInteger(lesson.order), `lessons[${index}].order must be an integer`);
    assertString(lesson.title, `lessons[${index}].title`);
    assertString(lesson.summary, `lessons[${index}].summary`);
    assertString(lesson.rule, `lessons[${index}].rule`);
    assert(validCategories.has(lesson.relatedCategory), `lessons[${index}].relatedCategory is invalid`);
  });

  data.forms.forEach((form, index) => {
    assert(validCategories.has(form.category), `forms[${index}].category is invalid`);
    assert(validVoices.has(form.voice), `forms[${index}].voice is invalid`);
    assertString(form.pronounLabel, `forms[${index}].pronounLabel`);
    assertString(form.arabic, `forms[${index}].arabic`);
    assertString(form.meaning, `forms[${index}].meaning`);
    assertString(form.rule, `forms[${index}].rule`);
  });

  data.practiceQuestions.forEach((question, index) => {
    assertString(question.prompt, `practiceQuestions[${index}].prompt`);
    assertString(question.arabic, `practiceQuestions[${index}].arabic`);
    assert(Array.isArray(question.options), `practiceQuestions[${index}].options must be an array`);
    assert(question.options.length >= 2, `practiceQuestions[${index}].options must have at least two items`);
    question.options.forEach((option, optionIndex) => {
      assertString(option, `practiceQuestions[${index}].options[${optionIndex}]`);
    });
    assertString(question.answer, `practiceQuestions[${index}].answer`);
    assert(
      question.options.includes(question.answer),
      `practiceQuestions[${index}].answer must exist in options`,
    );
    assertString(question.explanation, `practiceQuestions[${index}].explanation`);
  });

  console.log('Seed data valid');
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
