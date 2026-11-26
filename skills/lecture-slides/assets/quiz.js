// Reusable multiple-choice quiz component.
// Markup:
// <div class="quiz" data-answer="2">
//   <p class="q">Question?</p>
//   <button class="opt">A</button> <button class="opt">B</button> <button class="opt">C</button>
//   <p class="why">Explanation shown after answering.</p>
// </div>
// data-answer is the 0-based index of the correct option.
document.querySelectorAll('.quiz').forEach(function (quiz) {
  var answer = parseInt(quiz.dataset.answer, 10);
  var opts = quiz.querySelectorAll('button.opt');
  opts.forEach(function (btn, i) {
    btn.addEventListener('click', function () {
      opts.forEach(function (b, j) {
        b.disabled = true;
        if (j === answer) b.classList.add('right');
      });
      if (i !== answer) btn.classList.add('wrong');
      quiz.classList.add('done');
    });
  });
});
