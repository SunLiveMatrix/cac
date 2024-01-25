import * as React from "react";
interface UseAsyncControllableValueProps<E extends HTMLInputElement | HTMLTextAreaElement> {
    value?: React.InputHTMLAttributes<E>["value"];
    onChange?: React.ChangeEventHandler<E>;
    onCompositionStart?: React.CompositionEventHandler<E>;
    onCompositionEnd?: React.CompositionEventHandler<E>;
}
/**
 * The amount of time (in milliseconds) which the input will wait after a compositionEnd event before
 * unlocking its state value for external updates via props. See `handleCompositionEnd` for more details.
 */
export declare const ASYNC_CONTROLLABLE_VALUE_COMPOSITION_END_DELAY = 10;
export declare function useAsyncControllableValue<E extends HTMLInputElement | HTMLTextAreaElement>(props: UseAsyncControllableValueProps<E>): {
    onChange: React.ChangeEventHandler<E>;
    onCompositionEnd: React.CompositionEventHandler<E>;
    onCompositionStart: React.CompositionEventHandler<E>;
    value: string | number | readonly string[] | undefined;
};
export {};
