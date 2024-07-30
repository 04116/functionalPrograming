import "./styles.css";
import { items } from "./data.js";
import { useEffect, useState } from "react";

/**
 * - save checked item
 * - onClick move checked list to side defined by btn
 * - after move, reset checked list
 */

// this function return a React element
// component will be process by react runtime
// params will be fill by PARRENT element
function Item({ label, id, onCheckedChanged, checked }) {
  // on Item changed
  function onChange(event) {
    onCheckedChanged(id, event.target.checked);
  }

  return (
    <li style={{ listStyleType: "none" }}>
      <label style={{ display: "block" }}>
        <input type="checkbox" checked={checked} onChange={onChange} />
        {label}
      </label>
    </li>
  );
}

function DoubleList({ items, onChangedSides }) {
  let [checkedIDs, setCheckedIDs] = useState([]);

  // the KEY thing here
  // use 1 array to present side of item at INDEX
  // array corresponding to items. true=right, false/undefined=left
  let [sides, setSides] = useState([]);

  // every sides changed, call onChangedSides
  // just for logging now
  useEffect(() => {
    onChangedSides(sides);
  }, [sides, onChangedSides]);

  // cache checked item
  // check item will be used to move around
  function onCheckedChanged(id, isChecked) {
    setCheckedIDs((oldCheckedIDs) => {
      let newCheckedIDs = oldCheckedIDs.filter((cid) => cid !== id);
      if (isChecked) {
        newCheckedIDs.push(id);
      }
      return newCheckedIDs;
    });
  }

  function moveToSide(side) {
    setSides((oldSides) => {
      if (checkedIDs.length === 0) return oldSides;
      let newSides = [...oldSides];
      for (let id of checkedIDs) {
        newSides[id] = side;
      }
      return newSides;
    });

    // after move, reset checked list
    // here, setter can set a list (as value type)
    // or can use a function that transform from oldVal to newVal
    setCheckedIDs([]);
  }

  return (
    <div style={{ display: "grid", gridTemplateAreas: '"left buttons right"' }}>
      <ul
        style={{
          gridArea: "left",
          border: "1px solid #666",
          borderRadius: "1em",
          padding: "2em",
        }}
      >
        {items.map((item, id) =>
          !sides[id] ? (
            <Item
              label={item}
              id={id}
              onCheckedChanged={onCheckedChanged}
              key={id}
              // checked depend on global list INSTEAD of onCheckedChanged event cause
              // that list depend on two thing
              // 1- on onCheckedChanged - when user click
              // 2- when moved side (resetted)
              checked={checkedIDs.includes(id)}
            />
          ) : null
        )}
      </ul>
      <div
        style={{
          gridArea: "buttons",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <button
          style={{ padding: ".25em 1em", margin: ".5em" }}
          onClick={() => {
            moveToSide(false);
          }}
        >
          {"<"}
        </button>
        <button
          style={{ padding: ".25em 1em", margin: ".5em" }}
          onClick={() => {
            moveToSide(true);
          }}
        >
          {">"}
        </button>
      </div>
      <ul
        style={{
          gridArea: "right",
          border: "1px solid #666",
          borderRadius: "1em",
          padding: "2em",
        }}
      >
        {items.map((item, id) =>
          sides[id] ? (
            <Item
              label={item}
              id={id}
              onCheckedChanged={onCheckedChanged}
              key={id}
              checked={checkedIDs.includes(id)}
            />
          ) : null
        )}
      </ul>
    </div>
  );
}

export default function App() {
  return <DoubleList items={items} onChangedSides={console.log} />;
}
