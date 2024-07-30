import { computed, readonly, ref } from "vue";

type Marker = "x" | "o" | "-";

type Pos = {
  Row: number;
  Col: number;
};

export type Board = Array<Marker[]>;

//
// functional core
//

function move(
  history: Pos[],
  pos: Pos,
): {
  history: Pos[];
  success: boolean;
} {
  // can not make a move to existed pos
  for (let i = 0; i < history.length; i++) {
    if (history[i].Col === pos.Col && history[i].Row === pos.Row) {
      return { history: [...history], success: false };
    }
  }

  const newHist = [...history];
  newHist.push(pos);
  return {
    history: newHist,
    success: true,
  };
}

const undo = (histCurs: number): number => {
  return histCurs > 0 ? histCurs - 1 : 0;
};

const redo = (histCurs: number, histLen: number): number => {
  return histCurs < histLen ? histCurs + 1 : histLen;
};

const DIM_UPPER = 3;
const render = (initMarker: Marker, history: Pos[]): Board => {
  const board: Board = [];
  let marker = initMarker;

  // init
  for (let row = 0; row < DIM_UPPER; row++) {
    board[row] = [];
    for (let col = 0; col < DIM_UPPER; col++) {
      board[row][col] = "-";
    }
  }

  // restore history
  history.forEach((pos: Pos) => {
    board[pos.Row][pos.Col] = marker;
    marker = marker === "o" ? "x" : "o";
  });

  return board;
};

//
// imperative shell
//
export function useTicTacToe(_initMarker?: Marker) {
  const initMarker: Marker = _initMarker || "o";
  let history: Pos[] = [];

  // why we need tmp value?!
  // cause user can redo/undo many time before actually make a move
  const histCurs = ref(0);
  const board = computed(() => {
    const curHist = history.slice(0, histCurs.value);
    return render(initMarker, curHist);
  });

  function makeMove(pos: { row: number; col: number }) {
    // makeMove at current version
    const curHist = history.slice(0, histCurs.value);
    const moveRes = move(
      curHist,
      { Row: pos.row, Col: pos.col },
    );

    if (moveRes.success) {
      // if make a move success, we clear all rest history
      history = moveRes.history;

      histCurs.value += 1;
    }
  }

  function makeUndo() {
    histCurs.value = undo(histCurs.value);
  }

  function makeRedo() {
    histCurs.value = redo(histCurs.value, history.length);
  }

  return {
    makeMove,
    redo: makeRedo,
    undo: makeUndo,
    currentBoard: board,
  };
}
