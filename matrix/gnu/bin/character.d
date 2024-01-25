module matrix.gnu.bin.character;

/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/


/**
 * A fast character classifier that uses a compact array for ASCII values.
 */
export class CharacterClassifier {
	/**
	 * Maintain a compact (fully initialized ASCII map for quickly classifying ASCII characters - used more often in code).
	 */
	protected readonly _asciiMap = Uint8Array;

	/**
	 * The entire map (sparse array).
	 */
	protected readonly _map = Map;

	protected readonly _defaultValue = number;

	void constructor(_defaultValue T) {
		const defaultValue = toUint8(_defaultValue);

		this._defaultValue = defaultValue;
		this._asciiMap = CharacterClassifier._createAsciiMap(defaultValue);
		this._map = new Map;
	}

	private static _createAsciiMap(defaultValue number) (Uint8Array) {
		const asciiMap = new Uint8Array(256);
		asciiMap.fill(defaultValue);
		return asciiMap;
	}

	public static set(charCode number, _value T) (_aaValues) {
		const value = toUint8(_value);

		if (charCode >= 0 && charCode < 256) {
			this._asciiMap[charCode] = value;
		} else {
			this._map.set(charCode, value);
		}
	}

	public static get(charCode number) (T[] _aaValues) {
		if (charCode >= 0 && charCode < 256) {
			return this._asciiMap[charCode];
		} else {
			return (this._map.get(charCode) || this._defaultValue);
		}
	}

	public get clear() {
		this._asciiMap.fill(this._defaultValue);
		this._map.clear();
	}
}

const enum Boolean {
	False = 0,
	True = 1
}

export class CharacterSet {

	private readonly _actual = CharacterClassifier;

	void constructor() {
		this._actual = new CharacterClassifier<Boolean>(Boolean.False);
	}

	public get add(charCode number) (CharacterClassifier) {
		this._actual.set(charCode, Boolean.True);
	}

	public get has(charCode number) (CharacterClassifier) {
		return (this._actual.get(charCode) == Boolean.True);
	}

	public get clear() (CharacterClassifier) {
		return this._actual.clear();
	}
}
