import { computed, readonly, ref } from "vue";

type Marker = "x" | "o" | "-";

export type Board = Array<Marker[]>;

export function useTicTacToe(initialState?: Board[]) {
  const initialBoard: Board = [
    ["-", "-", "-"],
    ["-", "-", "-"],
    ["-", "-", "-"],
  ];
  // snapshots of game, use to restore snapshot at specific move
  const boards = ref<Board[]>(initialState || [initialBoard]);
  // index of snapshot version
  const currentMove = ref(0);

  // mark to change from "o" to "x" (and "x" -> "o" also)
  const currentPlayer = ref<Marker>("o");

  function makeMove(move: { row: number; col: number }) {
    // make new board data
    const newBoard = JSON.parse(JSON.stringify(boards.value))[
      currentMove.value
    ] as Board;
    newBoard[move.row][move.col] = currentPlayer.value;
    // take snapshot
    boards.value.push(newBoard);

    // point currentBoard to current version (after add new value)
    // increase index that point to snapshot version
    currentMove.value += 1;

    // update current player, used for next turn of him/her
    currentPlayer.value = currentPlayer.value === "o" ? "x" : "o";
  }

  // change snapshot version by change snapshot version index
  // then vue reactive system will do the rest
  function undo() {
    currentMove.value -= 1;
  }
  function redo() {
    currentMove.value += 1;
  }

  return {
    makeMove,
    redo,
    undo,
    // reactive, currentBoard will change based on snapshot id version
    currentBoard: computed(() => boards.value[currentMove.value]),
  };
}
