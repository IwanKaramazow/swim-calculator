@val @scope("process")
external argv: array<string> = "argv"

type paceInfo = {
  percentage: int,
  speedPer100m: float,
}

let percentages = [110, 105, 100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50]

let categoryInfo = `
PURE SPEED (over 110%)
SPECIFIC SPEED (110 - 90%)
SPECIAL SPEED (90 - 80%)
BASIC SPEED (80 - 65%)
GENERAL SPEED (65 - 50%)
REGENERATION (under 50%)
`

let computeSpeedTable = time400m => {
  switch time400m->Js.String2.split(":") {
  | [minutes, seconds] =>
    let totalSeconds =
      Belt.Float.fromInt(minutes->int_of_string * 60 + seconds->int_of_string) /. 4.
    let onePercent = totalSeconds *. 0.01

    Js.log(`Your 400m time: ${time400m}\n\nTraining speeds:\n----------------`)

    percentages
    ->Belt.Array.map(percentage => {
      percentage: percentage,
      speedPer100m: if percentage >= 100 {
        totalSeconds -. (percentage - 100)->Belt.Float.fromInt *. onePercent
      } else {
        totalSeconds +. (100 - percentage)->Belt.Float.fromInt *. onePercent
      },
    })
    ->Belt.Array.forEach(paceInfo => {
      let padding = paceInfo.percentage < 100 ? " " : ""
      let percentage = paceInfo.percentage->Belt.Int.toString
      let minutes = (paceInfo.speedPer100m->Belt.Float.toInt / 60)->Belt.Int.toString
      let seconds = {
        let n = mod_float(paceInfo.speedPer100m, 60.)->Js.Math.floor_float->Belt.Float.toString
        if n->Js.String2.length < 2 {
          `0${n}`
        } else {
          n
        }
      }

      Js.log(`${padding}${percentage}%: ${minutes}'${seconds}"`)
    })

    Js.log(categoryInfo)

  | _ => ()
  }
}

if argv->Belt.Array.length >= 3 {
  computeSpeedTable(argv->Belt.Array.getUnsafe(2))
}
