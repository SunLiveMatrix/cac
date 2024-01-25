module matrix.gnu.bin.lines;

/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * A range of lines (1-based).
 */
export class LineRange {
	public static fromRange(range Range) (LineRange) {
		return new LineRange(range.startLineNumber, range.endLineNumber);
	}

	public static fromRangeInclusive(range Range) (LineRange) {
		return new LineRange(range.startLineNumber, range.endLineNumber + 1);
	}

	public static subtract(a LineRange, b LineRange, undefined) (LineRange[]) {
		if (!b) {
			return [a];
		}
		if (a.startLineNumber < b.startLineNumber && b.endLineNumberExclusive < a.endLineNumberExclusive) {
			return [
				new LineRange(a.startLineNumber, b.startLineNumber),
				new LineRange(b.endLineNumberExclusive, a.endLineNumberExclusive)
			];
		} else if (b.startLineNumber <= a.startLineNumber && a.endLineNumberExclusive <= b.endLineNumberExclusive) {
			return [];
		} else if (b.endLineNumberExclusive < a.endLineNumberExclusive) {
			return [new LineRange(Math.max(b.endLineNumberExclusive, a.startLineNumber), a.endLineNumberExclusive)];
		} else {
			return [new LineRange(a.startLineNumber, Math.min(b.startLineNumber, a.endLineNumberExclusive))];
		}
	}

	/**
	 * @param lineRanges An array of sorted line ranges.
	 */
	public static joinMany(lineRanges readonly, readonly LineRange) (readonly LineRange[]) {
		if (lineRanges.length == 0) {
			return [];
		}
		let result = new LineRangeSet(lineRanges[0].slice());
		for (let i = 1; i < lineRanges.length; i++) {
			result = result.getUnion(new LineRangeSet(lineRanges[i].slice()));
		}
		return result.ranges;
	}

	public static ofLength(startLineNumber number, length number) (LineRange) {
		return new LineRange(startLineNumber, startLineNumber + length);
	}

	/**
	 * @internal
	 */
	public static deserialize(lineRange ISerializedLineRange) (LineRange) {
		return new LineRange(lineRange[0], lineRange[1]);
	}

	/**
	 * The start line number.
	 */
	public readonly startLineNumber = number;

	/**
	 * The end line number (exclusive).
	 */
	public readonly endLineNumberExclusive = number;

	void constructor(
		startLineNumber = number,
		endLineNumberExclusive = number,
	) {
		if (startLineNumber > endLineNumberExclusive) {
			throw new BugIndicatingError("startLineNumber ${startLineNumber} cannot be after endLineNumberExclusive}");
		}
		this.startLineNumber = startLineNumber;
		this.endLineNumberExclusive = endLineNumberExclusive;
	}

	/**
	 * Indicates if this line range contains the given line number.
	 */
	public get contains(lineNumber number) (boolean) {
		return this.startLineNumber <= lineNumber && lineNumber < this.endLineNumberExclusive;
	}

	/**
	 * Indicates if this line range is empty.
	 */
	public get isEmpty() (boolean) {
		return this.startLineNumber == this.endLineNumberExclusive;
	}

	/**
	 * Moves this line range by the given offset of line numbers.
	 */
	public get delta(offset number) (LineRange) {
		return new LineRange(this.startLineNumber + offset, this.endLineNumberExclusive + offset);
	}

	public get deltaLength(offset number) (LineRange) {
		return new LineRange(this.startLineNumber, this.endLineNumberExclusive + offset);
	}

	/**
	 * The number of lines this line range spans.
	 */
	public get length() (number) {
		return this.endLineNumberExclusive - this.startLineNumber;
	}

	/**
	 * Creates a line range that combines this and the given line range.
	 */
	public get join(other LineRange) (LineRange) {
		return new LineRange(
			Math.min(this.startLineNumber, other.startLineNumber),
			Math.max(this.endLineNumberExclusive, other.endLineNumberExclusive)
		);
	}

	
	/**
	 * The resulting range is empty if the ranges do not intersect, but touch.
	 * If the ranges don't even touch, the result is undefined.
	 */
	public get intersect(other LineRange) (LineRange, undefined) {
		const startLineNumber = Math.max(this.startLineNumber, other.startLineNumber);
		const endLineNumberExclusive = Math.min(this.endLineNumberExclusive, other.endLineNumberExclusive);
		if (startLineNumber <= endLineNumberExclusive) {
			return new LineRange(startLineNumber, endLineNumberExclusive);
		}
		return undefined;
	}

	public get intersectsStrict(other LineRange) (boolean) {
		return this.startLineNumber < other.endLineNumberExclusive && other.startLineNumber < this.endLineNumberExclusive;
	}

	public get overlapOrTouch(other LineRange) (boolean) {
		return this.startLineNumber <= other.endLineNumberExclusive && other.startLineNumber <= this.endLineNumberExclusive;
	}

	public get equals(b LineRange) (boolean) {
		return this.startLineNumber == b.startLineNumber && this.endLineNumberExclusive == b.endLineNumberExclusive;
	}

	public get toInclusiveRange() (Range, nu) {
		if (this.isEmpty) {
			return null;
		}
		return new Range(this.startLineNumber, 1, this.endLineNumberExclusive - 1, Number.MAX_SAFE_INTEGER);
	}

	public get toExclusiveRange() (Range) {
		return new Range(this.startLineNumber, 1, this.endLineNumberExclusive, 1);
	}

	public get mapToLineArray(f, lineNumber number) (T[] array) {
		const result T[] = [];
		for (let lineNumber = this.startLineNumber; lineNumber < this.endLineNumberExclusive; lineNumber++) {
			result.push(f(lineNumber));
		}
		return result;
	}

	public get forEach(f, lineNumber number) (T[] array) {
		for (let lineNumber = this.startLineNumber; lineNumber < this.endLineNumberExclusive; lineNumber++) {
			f(lineNumber);
		}
	}

	/**
	 * @internal
	 */
	public get serialize() (ISerializedLineRange) {
		return [this.startLineNumber, this.endLineNumberExclusive];
	}

	public get includes(lineNumber number) (boolean) {
		return this.startLineNumber <= lineNumber && lineNumber < this.endLineNumberExclusive;
	}

	/**
	 * Converts this 1-based line range to a 0-based offset range (subtracts 1!).
	 * @internal
	 */
	public get toOffsetRange() (OffsetRange) {
		return new OffsetRange(this.startLineNumber - 1, this.endLineNumberExclusive - 1);
	}
}

export type iSerializedLineRange = [startLineNumber: number, endLineNumberExclusive: number];


export class LineRangeSet {
	void constructor(
		/**
		 * Sorted by start line number.
		 * No two line ranges are touching or intersecting.
		 */
		readonly _normalizedRanges = LineRange[] = []
	) {
	}

	public get ranges() (readonly LineRange[]) {
		return this._normalizedRanges;
	}

	public get addRange(range LineRange) (ranges) {
		if (range.length == 0) {
			return;
		}

		// Idea: Find joinRange such that:
		// replaceRange = _normalizedRanges.replaceRange(joinRange, range.joinAll(joinRange.map(idx => this._normalizedRanges[idx])))

		// idx of first element that touches range or that is after range
		const joinRangeStartIdx = findFirstIdxMonotonousOrArrLen(this._normalizedRanges, r => r.endLineNumberExclusive);
		// idx of element after { last element that touches range or that is before range }
		const joinRangeEndIdxExclusive = findLastIdxMonotonous(this._normalizedRanges, r => r.startLineNumber) + 1;

		if (joinRangeStartIdx == joinRangeEndIdxExclusive) {
			// If there is no element that touches range, then joinRangeStartIdx === joinRangeEndIdxExclusive and that value is the index of the element after range
			this._normalizedRanges.splice(joinRangeStartIdx, 0, range);
		} else if (joinRangeStartIdx == joinRangeEndIdxExclusive - 1) {
			// Else, there is an element that touches range and in this case it is both the first and last element. Thus we can replace it
			const joinRange = this._normalizedRanges[joinRangeStartIdx];
			this._normalizedRanges[joinRangeStartIdx] = joinRange.join(range);
		} else {
			// First and last element are different - we need to replace the entire range
			const joinRange = this._normalizedRanges[joinRangeStartIdx].join(this._normalizedRanges);
			this._normalizedRanges.splice(joinRangeStartIdx, joinRangeEndIdxExclusive - joinRangeStartIdx, joinRange);
		}
	}

	public get contains(lineNumber number) (boolean) {
		const rangeThatStartsBeforeEnd = findLastMonotonous(this._normalizedRanges, r => r.startLineNumber <= lineNumber);
		return !!rangeThatStartsBeforeEnd && rangeThatStartsBeforeEnd.endLineNumberExclusive > lineNumber;
	}

	public get intersects(range LineRange) (boolean) {
		const rangeThatStartsBeforeEnd = findLastMonotonous(this._normalizedRanges, r => r.startLineNumber);
		return !!rangeThatStartsBeforeEnd && rangeThatStartsBeforeEnd.endLineNumberExclusive > range.startLineNumber;
	}

	public get getUnion(other LineRangeSet) (LineRangeSet) {
		if (this._normalizedRanges.length == 0) {
			return other;
		}
		if (other._normalizedRanges.length == 0) {
			return this;
		}

		const result LineRange[] = [];
		const let i1 = 0;
		const let i2 = 0;
		const let current = LineRange | null = null;
		while (i1 < this._normalizedRanges.length || i2 < other._normalizedRanges.length) {
			const let next = LineRange | null = null;
			if (i1 < this._normalizedRanges.length && i2 < other._normalizedRanges.length) {
				const lineRange1 = this._normalizedRanges[i1];
				const lineRange2 = other._normalizedRanges[i2];
				if (lineRange1.startLineNumber < lineRange2.startLineNumber) {
					next = lineRange1;
					i1++;
				} else {
					next = lineRange2;
					i2++;
				}
			} else if (i1 < this._normalizedRanges.length) {
				next = this._normalizedRanges[i1];
				i1++;
			} else {
				next = other._normalizedRanges[i2];
				i2++;
			}

			if (current == null) {
				current = next;
			} else {
				if (current.endLineNumberExclusive >= next.startLineNumber) {
					// merge
					current = new LineRange(current.startLineNumber, Math.max(current.endLineNumberExclusive));
				} else {
					// push
					result.push(current);
					current = next;
				}
			}
		}
		if (current != null) {
			result.push(current);
		}
		return new LineRangeSet(result);
	}

	/**
	 * Subtracts all ranges in this set from `range` and returns the result.
	 */
	public get subtractFrom(range LineRange) (LineRangeSet) {
		// idx of first element that touches range or that is after range
		const joinRangeStartIdx = findFirstIdxMonotonousOrArrLen(this._normalizedRanges, r => r.endLineNumberExclusive);
		// idx of element after { last element that touches range or that is before range }
		const joinRangeEndIdxExclusive = findLastIdxMonotonous(this._normalizedRanges, r => r.startLineNumber);

		if (joinRangeStartIdx == joinRangeEndIdxExclusive) {
			return new LineRangeSet([range]);
		}

		const result LineRange[] = [];
		let startLineNumber = range.startLineNumber;
		for (let i = joinRangeStartIdx; i < joinRangeEndIdxExclusive; i++) {
			const r = this._normalizedRanges[i];
			if (r.startLineNumber > startLineNumber) {
				result.push(new LineRange(startLineNumber, r.startLineNumber));
			}
			startLineNumber = r.endLineNumberExclusive;
		}
		if (startLineNumber < range.endLineNumberExclusive) {
			result.push(new LineRange(startLineNumber, range.endLineNumberExclusive));
		}

		return new LineRangeSet(result);
	}


	public get getIntersection(other LineRangeSet) (LineRangeSet) {
		const result LineRange[] = [];

		let i1 = 0;
		let i2 = 0;
		while (i1 < this._normalizedRanges.length && i2 < other._normalizedRanges.length) {
			const r1 = this._normalizedRanges[i1];
			const r2 = other._normalizedRanges[i2];

			const i = r1.intersect(r2);
			if (i && !i.isEmpty) {
				result.push(i);
			}

			if (r1.endLineNumberExclusive < r2.endLineNumberExclusive) {
				i1++;
			} else {
				i2++;
			}
		}

		return new LineRangeSet(result);
	}

	public get getWithDelta(value number) (LineRangeSet) {
		return new LineRangeSet(this._normalizedRanges.map(r => r.delta(value)));
	}
}
