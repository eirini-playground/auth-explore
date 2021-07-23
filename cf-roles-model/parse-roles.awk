function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }

BEGIN { FS="|" }
/Permitted [Rr]oles/ { start=1; next }
/^\|?\s*--/ { next }
/^$/ { next }
/^\|?\s*Role[s]?\s*\|/ { next }
/^.+\|.*/ {
    if (start == 0) {
        next
    }

    roleIndex = 0
    role=""
    note=""

    for(i=1; i<=NF; i++) {
        if($i == "") {
            continue
        }
        if (roleIndex == 0) {
            roleIndex = i
            role = $i
            role = trim(role)
        } else {
          note = $i
          note=trim(note)
        }

    }

    if (role == "" && note == "") {
        next
    }

    if (role != "") {
      print role "|" note
    }
}

