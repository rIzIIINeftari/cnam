'use strict';
const mode = document.querySelector('#mode');
const difficulty = document.querySelector('#difficulty');
const symbol = document.querySelector('#symbol');
const statusText = document.querySelector('#status');
const boardElement = document.querySelector('#board');
let board, turn, timer;
const cells = Array.from({ length: 9 }, (_, i) => {
  const cell = document.createElement('button');
  cell.className = 'cell';
  cell.type = 'button';
  cell.addEventListener('click', () => {
    if (Morpion.result(board) || board[i] || isComputerTurn()) return;
    play(i);
    scheduleComputer();
  });
  boardElement.append(cell);
  return cell;
});
function isComputerTurn() { return mode.value === 'ai' && turn !== symbol.value; }
function render() {
  const end = Morpion.result(board);
  cells.forEach((cell, i) => {
    cell.textContent = board[i];
    cell.className = `cell ${board[i] === 'O' ? 'o' : ''} ${end?.line.includes(i) ? 'win' : ''}`;
    cell.disabled = Boolean(board[i] || end || isComputerTurn());
    cell.setAttribute('aria-label', `Ligne ${Math.floor(i / 3) + 1}, colonne ${i % 3 + 1} : ${board[i] || 'vide'}`);
  });
  if (end) {
    statusText.textContent = end.winner === 'draw' ? 'Égalité. On rejoue ?' : mode.value === 'local' ? `Le joueur ${end.winner} gagne !` : end.winner === symbol.value ? 'Bien joué, tu as gagné !' : 'L’ordinateur a gagné !';
  } else {
    statusText.textContent = mode.value === 'local' ? `Au tour du joueur ${turn}` : isComputerTurn() ? `L’ordinateur réfléchit · ${turn}` : `À toi de jouer · ${turn}`;
  }
}
function play(i) { board[i] = turn; turn = Morpion.other(turn); render(); }
function scheduleComputer() {
  if (Morpion.result(board) || !isComputerTurn()) return;
  timer = setTimeout(() => {
    const move = Morpion.chooseMove(board, turn, difficulty.value);
    if (move !== null) play(move);
  }, 350);
}
function restart() {
  clearTimeout(timer);
  board = Array(9).fill('');
  turn = 'X';
  document.querySelector('#ai-settings').hidden = mode.value === 'local';
  document.querySelector('#badge').textContent = mode.value === 'local' ? 'VS UN AMI' : 'VS ORDINATEUR';
  document.querySelector('#hint').textContent = mode.value === 'local' ? 'Jouez chacun votre tour sur le même appareil. X ouvre le duel !' : {
    easy: 'Il joue au hasard. Idéal pour découvrir le jeu et tenter tes premières stratégies.',
    medium: 'Il repère les victoires et bloque tes alignements. À toi de le surprendre !',
    unbeatable: 'Il joue chaque coup à la perfection. Arriveras-tu à faire match nul ?'
  }[difficulty.value];
  render();
  scheduleComputer();
}
[mode, difficulty, symbol].forEach(control => control.addEventListener('change', restart));
document.querySelector('#restart').addEventListener('click', restart);
restart();
