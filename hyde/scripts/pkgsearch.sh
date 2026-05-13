#!/usr/bin/env bash
# Search repo + AUR with yay, pick in rofi, install in a terminal (HyDE-friendly).
set -euo pipefail
shopt -s extglob

if [[ ${HYDE_SHELL_INIT:-0} -ne 1 ]]; then
	# shellcheck disable=SC1091
	eval "$(hyde-shell init)"
else
	export_hyde_config
fi

if command -v yay >/dev/null 2>&1; then
	PM=(yay -Ss --topdown)
elif command -v paru >/dev/null 2>&1; then
	PM=(paru -Ss)
else
	PM=(pacman -Ss)
fi

setup_rofi() {
	local font_scale=${ROFI_SCALE:-10}
	local font_name=${ROFI_FONT:-$(get_hyprConf "MENU_FONT")}
	font_name=${font_name:-$(get_hyprConf "FONT")}
	font_name=${font_name:-'JetBrainsMono Nerd Font'}
	font_override="* {font: \"${font_name} ${font_scale}\";}"
	local hypr_border=${hypr_border:-"$(hyprctl -j getoption decoration:rounding 2>/dev/null | jq -r '.int // 10')"}
	local wind_border=$((hypr_border * 3 / 2))
	local elem_border=$((hypr_border == 0 ? 5 : hypr_border))
	rofi_position=$(get_rofi_pos)
	local hypr_width=${hypr_width:-"$(hyprctl -j getoption general:border_size 2>/dev/null | jq -r '.int // 2')"}
	r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;}listview{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
	export ROFI_FONT_OVERRIDE="$font_override"
	export ROFI_R_OVERRIDE="$r_override"
	export ROFI_POSITION="$rofi_position"
}

pick_terminal() {
	if [[ -n ${TERMINAL:-} ]] && command -v "$TERMINAL" >/dev/null 2>&1; then
		printf '%s\n' "$TERMINAL"
		return
	fi
	for t in kitty foot alacritty ghostty wezterm org.wezfurlong.wezterm xterm; do
		command -v "$t" >/dev/null 2>&1 || continue
		printf '%s\n' "$t"
		return
	done
	return 1
}

run_install_term() {
	local pkg=$1
	local inner install_q
	# Quote full install argv for bash -lc (handles sudo pacman -S).
	if command -v yay >/dev/null 2>&1; then
		install_q=$(printf 'yay -S %q' "$pkg")
	elif command -v paru >/dev/null 2>&1; then
		install_q=$(printf 'paru -S %q' "$pkg")
	else
		install_q=$(printf 'sudo pacman -S %q' "$pkg")
	fi
	inner="echo '→' ${install_q}; ${install_q}; st=\$?; echo; if [[ \$st -ne 0 ]]; then read -rsp 'Failed (press Enter)...' _; else read -rsp 'Done (press Enter)...' _; fi"
	local term_exec
	term_exec=$(pick_terminal) || {
		notify-send -a "pkgsearch" "No terminal found" "Set \$TERMINAL or install kitty/foot."
		return 1
	}
	case "$term_exec" in
	kitty) "$term_exec" bash -lc "$inner" ;;
	foot | alacritty | ghostty | wezterm | org.wezfurlong.wezterm | xterm) "$term_exec" -e bash -lc "$inner" ;;
	*) "$term_exec" -e bash -lc "$inner" ;;
	esac
}

# shellcheck disable=SC2154
rofi_ask() {
	local placeholder=$1
	shift
	rofi -dmenu -i -p "$placeholder" -theme "clipboard" -matching fuzzy "$@" \
		-theme-str "entry { placeholder: \"${placeholder}\"; } ${ROFI_POSITION} ${ROFI_R_OVERRIDE}" \
		-theme-str "${ROFI_FONT_OVERRIDE}"
}

collect_matches() {
	local query=$1
	local tmp lines
	tmp=$(mktemp)
	# shellcheck disable=SC2068
	"${PM[@]}" "$query" 2>/dev/null | head -500 >"$tmp" || true
	if [[ ! -s "$tmp" ]]; then
		rm -f "$tmp"
		return 1
	fi
	local pkg="" desc="" line
	while IFS= read -r line || [[ -n "$line" ]]; do
		[[ -z "$line" ]] && continue
		if [[ "$line" =~ ^[[:space:]] ]]; then
			desc+=' '
			desc+=${line##+([[:space:]])}
		else
			[[ -n "$pkg" ]] && printf '%s\t%s\n' "$pkg" "$desc"
			pkg=${line%% *}
			desc=${line#"$pkg"}
			desc=${desc##+([[:space:]])}
		fi
	done <"$tmp"
	[[ -n "$pkg" ]] && printf '%s\t%s\n' "$pkg" "$desc"
	rm -f "$tmp"
}

main() {
	setup_rofi
	local query selected display
	query=$(rofi_ask " Search packages (pacman/AUR)… ")
	[[ -z "${query// }" ]] && exit 0

	local list
	list=$(collect_matches "$query") || {
		notify-send -a "pkgsearch" "No results" "Nothing matched «$query»."
		exit 0
	}

	display=$(while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		row_pkg=${line%%$'\t'*}
		row_rest=${line#*$'\t'}
		printf '%s — %s\n' "$row_pkg" "$row_rest"
	done <<<"$list")

	selected=$(printf '%s\n' "$display" | rofi_ask " Pick package to install… " -l 18 -width 75)
	[[ -z "$selected" ]] && exit 0

	local want_pkg
	want_pkg=${selected%% — *}
	[[ -z "$want_pkg" ]] && exit 0
	if [[ ! "$want_pkg" =~ ^[a-zA-Z0-9._@+/:+-]+$ ]]; then
		notify-send -a "pkgsearch" "Invalid selection" "$want_pkg"
		exit 1
	fi

	run_install_term "$want_pkg"
}

main "$@"
