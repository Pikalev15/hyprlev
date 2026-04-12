/// <reference path="./gio-2.0.d.ts" />
/// <reference path="./gobject-2.0.d.ts" />
/// <reference path="./glib-2.0.d.ts" />
/// <reference path="./gmodule-2.0.d.ts" />

/**
 * Type Definitions for Gjs (https://gjs.guide/)
 *
 * These type definitions are automatically generated, do not edit them by hand.
 * If you found a bug fix it in `ts-for-gir` or create a bug report on https://github.com/gjsify/ts-for-gir
 *
 * The based EJS template file is used for the generated .d.ts file of each GIR module like Gtk-4.0, GObject-2.0, ...
 */

declare module 'gi://Nautilus?version=4.1' {
    // Module dependencies
    import type Gio from 'gi://Gio?version=2.0';
    import type GObject from 'gi://GObject?version=2.0';
    import type GLib from 'gi://GLib?version=2.0';
    import type GModule from 'gi://GModule?version=2.0';

    export namespace Nautilus {
        /**
         * Nautilus-4.1
         */

        /**
         * Return values for asynchronous operations performed by the extension.
         */

        /**
         * Return values for asynchronous operations performed by the extension.
         */
        export namespace OperationResult {
            export const $gtype: GObject.GType<OperationResult>;
        }

        enum OperationResult {
            /**
             * the operation succeeded, and the extension
             *  is done with the request.
             */
            COMPLETE,
            /**
             * the operation failed.
             */
            FAILED,
            /**
             * the extension has begin an async operation.
             *  When this value is returned, the extension must set the handle parameter
             *  and call the callback closure when the operation is complete.
             */
            IN_PROGRESS,
        }
        /**
         * Get an existing `NautilusFileInfo` (if it exists) or create a new one is it
         * does not exist.
         * @param location the location to create the file info for
         */
        function file_info_create(location: Gio.File): FileInfo;
        /**
         * Get an existing `NautilusFileInfo` (if it exists) or create a new one is it
         * does not exist.
         * @param uri the URI to lookup the file info for
         */
        function file_info_create_for_uri(uri: string): FileInfo;
        /**
         * Deep copy a list of `NautilusFileInfo`.
         * @param files the files to copy
         * @returns a copy of @files.  Use [func@FileInfo.list_free] to free the list and unref its contents.
         */
        function file_info_list_copy(files: FileInfo[]): FileInfo[];
        /**
         * Deep free a list of `NautilusFileInfo`.
         * @param files a list created with [func@FileInfo.list_copy]
         */
        function file_info_list_free(files: FileInfo[]): void;
        /**
         * Get an existing `NautilusFileInfo` or `NULL` if it does not exist in the
         * application cache.
         * @param location the location for which to look up a corresponding #NautilusFileInfo object
         */
        function file_info_lookup(location: Gio.File): FileInfo | null;
        /**
         * Get an existing `NautilusFileInfo` or `NULL` if it does not exist in the
         * application cache.
         * @param uri the URI to lookup the file info for
         */
        function file_info_lookup_for_uri(uri: string): FileInfo | null;
        /**
         * Complete an async file info update.
         * @param update_complete the closure to call
         * @param provider an info provider
         * @param handle the handle for the given closure
         * @param result either `NAUTILUS_OPERATION_COMPLETE` or `NAUTILUS_OPERATION_FAILED`
         */
        function info_provider_update_complete_invoke(
            update_complete: GObject.Closure,
            provider: InfoProvider,
            handle: OperationHandle,
            result: OperationResult | null,
        ): void;
        namespace Column {
            // Signal signatures
            interface SignalSignatures extends GObject.Object.SignalSignatures {
                'notify::attribute': (pspec: GObject.ParamSpec) => void;
                'notify::attribute-q': (pspec: GObject.ParamSpec) => void;
                'notify::default-sort-order': (pspec: GObject.ParamSpec) => void;
                'notify::description': (pspec: GObject.ParamSpec) => void;
                'notify::label': (pspec: GObject.ParamSpec) => void;
                'notify::name': (pspec: GObject.ParamSpec) => void;
                'notify::visible': (pspec: GObject.ParamSpec) => void;
                'notify::xalign': (pspec: GObject.ParamSpec) => void;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {
                attribute: string;
                attribute_q: number;
                attributeQ: number;
                default_sort_order: boolean;
                defaultSortOrder: boolean;
                description: string;
                label: string;
                name: string;
                visible: boolean;
                xalign: number;
            }
        }

        /**
         * List view column descriptor object.
         *
         * `NautilusColumn` is an object that describes a column in the file manager
         * list view. Extensions can provide `NautilusColumn` by registering a
         * [iface`ColumnProvider]` and returning them from
         * [method`ColumnProvider`.get_columns], which will be called by the main
         * application when creating a view.
         */
        class Column extends GObject.Object {
            static $gtype: GObject.GType<Column>;

            // Properties

            /**
             * The file attribute to be displayed in the column.
             */
            get attribute(): string;
            set attribute(val: string);
            get attribute_q(): number;
            get attributeQ(): number;
            /**
             * The enum values of GtkSortType
             *
             * Uses enum because we don't want extensions to depend on Gtk. This property
             * is not meant to be used by extensions.
             */
            get default_sort_order(): boolean;
            set default_sort_order(val: boolean);
            /**
             * The enum values of GtkSortType
             *
             * Uses enum because we don't want extensions to depend on Gtk. This property
             * is not meant to be used by extensions.
             */
            get defaultSortOrder(): boolean;
            set defaultSortOrder(val: boolean);
            /**
             * The user-visible description of the column.
             */
            get description(): string;
            set description(val: string);
            /**
             * The label to display in the column.
             */
            get label(): string;
            set label(val: string);
            /**
             * The identifier for the column.
             */
            get name(): string;
            /**
             * Whether to show the NautilusColumn in a ColumnChooser.
             *
             * This is not meant to be used by extensions. The value may be changed
             * over the life of the NautilusColumn.
             */
            get visible(): boolean;
            set visible(val: boolean);
            /**
             * The x-alignment of the column.
             */
            get xalign(): number;
            set xalign(val: number);

            /**
             * Compile-time signal type information.
             *
             * This instance property is generated only for TypeScript type checking.
             * It is not defined at runtime and should not be accessed in JS code.
             * @internal
             */
            $signals: Column.SignalSignatures;

            // Constructors

            constructor(properties?: Partial<Column.ConstructorProps>, ...args: any[]);

            _init(...args: any[]): void;

            static ['new'](name: string, attribute: string, label: string, description: string): Column;

            // Signals

            connect<K extends keyof Column.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, Column.SignalSignatures[K]>,
            ): number;
            connect(signal: string, callback: (...args: any[]) => any): number;
            connect_after<K extends keyof Column.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, Column.SignalSignatures[K]>,
            ): number;
            connect_after(signal: string, callback: (...args: any[]) => any): number;
            emit<K extends keyof Column.SignalSignatures>(
                signal: K,
                ...args: GObject.GjsParameters<Column.SignalSignatures[K]> extends [any, ...infer Q] ? Q : never
            ): void;
            emit(signal: string, ...args: any[]): void;
        }

        namespace Menu {
            // Signal signatures
            interface SignalSignatures extends GObject.Object.SignalSignatures {}

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {}
        }

        /**
         * A submenu linked to a [class`NautilusMenuItem]`.
         *
         * `NautilusMenu` is an object that describes a submenu in a file manager
         * menu. Extensions can provide `NautilusMenu` objects by attaching them to
         * `NautilusMenuItem` objects, using [method`NautilusMenuItem`.set_submenu].
         */
        class Menu extends GObject.Object {
            static $gtype: GObject.GType<Menu>;

            /**
             * Compile-time signal type information.
             *
             * This instance property is generated only for TypeScript type checking.
             * It is not defined at runtime and should not be accessed in JS code.
             * @internal
             */
            $signals: Menu.SignalSignatures;

            // Constructors

            constructor(properties?: Partial<Menu.ConstructorProps>, ...args: any[]);

            _init(...args: any[]): void;

            static ['new'](): Menu;

            // Signals

            connect<K extends keyof Menu.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, Menu.SignalSignatures[K]>,
            ): number;
            connect(signal: string, callback: (...args: any[]) => any): number;
            connect_after<K extends keyof Menu.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, Menu.SignalSignatures[K]>,
            ): number;
            connect_after(signal: string, callback: (...args: any[]) => any): number;
            emit<K extends keyof Menu.SignalSignatures>(
                signal: K,
                ...args: GObject.GjsParameters<Menu.SignalSignatures[K]> extends [any, ...infer Q] ? Q : never
            ): void;
            emit(signal: string, ...args: any[]): void;

            // Methods

            /**
             * Append a [class`NautilusMenuItem]` to the current `NautilusMenu`.
             * @param item
             */
            append_item(item: MenuItem): void;
            /**
             * Get a list of [class`NautilusMenuItem]` for the current `NautilusMenu`.
             * @returns the provided #NautilusMenuItem list
             */
            get_items(): MenuItem[] | null;
        }

        namespace MenuItem {
            // Signal signatures
            interface SignalSignatures extends GObject.Object.SignalSignatures {
                activate: () => void;
                'notify::icon': (pspec: GObject.ParamSpec) => void;
                'notify::label': (pspec: GObject.ParamSpec) => void;
                'notify::menu': (pspec: GObject.ParamSpec) => void;
                'notify::name': (pspec: GObject.ParamSpec) => void;
                'notify::priority': (pspec: GObject.ParamSpec) => void;
                'notify::sensitive': (pspec: GObject.ParamSpec) => void;
                'notify::tip': (pspec: GObject.ParamSpec) => void;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {
                icon: string;
                label: string;
                menu: Menu;
                name: string;
                priority: boolean;
                sensitive: boolean;
                tip: string;
            }
        }

        /**
         * An individual item with a Nautilus context menu.
         *
         * `NautilusMenuItem` is an object that describes an item in a file manager
         * menu. Extensions can provide `NautilusMenuItem` objects by registering a
         * [iface`NautilusMenuProvider]` and returning them from
         * [method`NautilusMenuProvider`.get_file_items], or
         * [method`NautilusMenuProvider`.get_background_items], which will be called by the
         * main application when creating menus.
         */
        class MenuItem extends GObject.Object {
            static $gtype: GObject.GType<MenuItem>;

            // Properties

            /**
             * This property has no effect.
             */
            get icon(): string;
            set icon(val: string);
            /**
             * A user visible string describing the `NautilusMenuItem`.
             */
            get label(): string;
            set label(val: string);
            /**
             * A submenu for the current `NautilusMenuItem`.
             */
            get menu(): Menu;
            set menu(val: Menu);
            /**
             * A unique identifier for the `NautilusMenuItem`.  This is not user visible.
             */
            get name(): string;
            /**
             * This property has no effect.
             */
            get priority(): boolean;
            set priority(val: boolean);
            /**
             * Whether the `NautilusMenuItem` should be sensitive (i.e. clickable).
             */
            get sensitive(): boolean;
            set sensitive(val: boolean);
            /**
             * This property has no effect.
             */
            get tip(): string;
            set tip(val: string);

            /**
             * Compile-time signal type information.
             *
             * This instance property is generated only for TypeScript type checking.
             * It is not defined at runtime and should not be accessed in JS code.
             * @internal
             */
            $signals: MenuItem.SignalSignatures;

            // Constructors

            constructor(properties?: Partial<MenuItem.ConstructorProps>, ...args: any[]);

            _init(...args: any[]): void;

            static ['new'](name: string, label: string, tip?: string | null, icon?: string | null): MenuItem;

            // Signals

            connect<K extends keyof MenuItem.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, MenuItem.SignalSignatures[K]>,
            ): number;
            connect(signal: string, callback: (...args: any[]) => any): number;
            connect_after<K extends keyof MenuItem.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, MenuItem.SignalSignatures[K]>,
            ): number;
            connect_after(signal: string, callback: (...args: any[]) => any): number;
            emit<K extends keyof MenuItem.SignalSignatures>(
                signal: K,
                ...args: GObject.GjsParameters<MenuItem.SignalSignatures[K]> extends [any, ...infer Q] ? Q : never
            ): void;
            emit(signal: string, ...args: any[]): void;

            // Static methods

            /**
             * Deep frees a list of `NautilusMenuItem`.
             * @param item_list a list of #NautilusMenuItem
             */
            static list_free(item_list: MenuItem[]): void;

            // Virtual methods

            /**
             * Emits #NautilusMenuItem::activate.
             */
            vfunc_activate(): void;

            // Methods

            /**
             * Emits #NautilusMenuItem::activate.
             */
            activate(): void;
            /**
             * Attaches a menu to the given #NautilusMenuItem.
             * @param menu pointer to a #NautilusMenu to attach to the button
             */
            set_submenu(menu: Menu): void;
        }

        namespace PropertiesItem {
            // Signal signatures
            interface SignalSignatures extends GObject.Object.SignalSignatures {
                'notify::name': (pspec: GObject.ParamSpec) => void;
                'notify::value': (pspec: GObject.ParamSpec) => void;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {
                name: string;
                value: string;
            }
        }

        /**
         * A single element in a file's properties.
         *
         * A file's properties will consist of one or more `NautilusPropertiesItem`.
         * Each item is a name/value pair.  Items are added to their corresponding
         * [property`NautilusPropertiesModel:`model].
         */
        class PropertiesItem extends GObject.Object {
            static $gtype: GObject.GType<PropertiesItem>;

            // Properties

            /**
             * The user-visible name.
             */
            get name(): string;
            /**
             * The user-visible value.
             */
            get value(): string;

            /**
             * Compile-time signal type information.
             *
             * This instance property is generated only for TypeScript type checking.
             * It is not defined at runtime and should not be accessed in JS code.
             * @internal
             */
            $signals: PropertiesItem.SignalSignatures;

            // Constructors

            constructor(properties?: Partial<PropertiesItem.ConstructorProps>, ...args: any[]);

            _init(...args: any[]): void;

            static ['new'](name: string, value: string): PropertiesItem;

            // Signals

            connect<K extends keyof PropertiesItem.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, PropertiesItem.SignalSignatures[K]>,
            ): number;
            connect(signal: string, callback: (...args: any[]) => any): number;
            connect_after<K extends keyof PropertiesItem.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, PropertiesItem.SignalSignatures[K]>,
            ): number;
            connect_after(signal: string, callback: (...args: any[]) => any): number;
            emit<K extends keyof PropertiesItem.SignalSignatures>(
                signal: K,
                ...args: GObject.GjsParameters<PropertiesItem.SignalSignatures[K]> extends [any, ...infer Q] ? Q : never
            ): void;
            emit(signal: string, ...args: any[]): void;

            // Methods

            /**
             * Get the name.
             * @returns the name of this `NautilusPropertiesItem`
             */
            get_name(): string;
            /**
             * Get the value.
             * @returns the value of this `NautilusPropertiesItem`
             */
            get_value(): string;
        }

        namespace PropertiesModel {
            // Signal signatures
            interface SignalSignatures extends GObject.Object.SignalSignatures {
                'notify::model': (pspec: GObject.ParamSpec) => void;
                'notify::title': (pspec: GObject.ParamSpec) => void;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {
                model: Gio.ListModel;
                title: string;
            }
        }

        /**
         * A model to implement custom file Properties.
         *
         * `NautilusPropertiesModel` is an model that describes a set of file properties.
         * Extensions can provide `NautilusPropertiesModel` objects by registering a
         * [iface`PropertiesModelProvider]` and returning them from
         * [method`PropertiesModelProvider`.get_models], which will be called by
         * the main application when creating file properties.
         */
        class PropertiesModel extends GObject.Object {
            static $gtype: GObject.GType<PropertiesModel>;

            // Properties

            /**
             * The item model.
             */
            get model(): Gio.ListModel;
            /**
             * The user visible title
             */
            get title(): string;
            set title(val: string);

            /**
             * Compile-time signal type information.
             *
             * This instance property is generated only for TypeScript type checking.
             * It is not defined at runtime and should not be accessed in JS code.
             * @internal
             */
            $signals: PropertiesModel.SignalSignatures;

            // Constructors

            constructor(properties?: Partial<PropertiesModel.ConstructorProps>, ...args: any[]);

            _init(...args: any[]): void;

            static ['new'](title: string, model: Gio.ListModel): PropertiesModel;

            // Signals

            connect<K extends keyof PropertiesModel.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, PropertiesModel.SignalSignatures[K]>,
            ): number;
            connect(signal: string, callback: (...args: any[]) => any): number;
            connect_after<K extends keyof PropertiesModel.SignalSignatures>(
                signal: K,
                callback: GObject.SignalCallback<this, PropertiesModel.SignalSignatures[K]>,
            ): number;
            connect_after(signal: string, callback: (...args: any[]) => any): number;
            emit<K extends keyof PropertiesModel.SignalSignatures>(
                signal: K,
                ...args: GObject.GjsParameters<PropertiesModel.SignalSignatures[K]> extends [any, ...infer Q]
                    ? Q
                    : never
            ): void;
            emit(signal: string, ...args: any[]): void;

            // Methods

            /**
             * Gets the properties items provided by this model.
             * @returns a [iface@Gio.ListModel] containing [class@PropertiesItem].
             */
            get_model(): Gio.ListModel;
            /**
             * Get the user-visible title.
             * @returns the title of this #NautilusPropertiesModel
             */
            get_title(): string;
            /**
             * Set a user-visible name for the set of properties in this model.
             *
             * It should work both as a window title and as a boxed list row.
             * Exactly where it is shown in the UI may vary in the future.
             * @param title the new title
             */
            set_title(title: string): void;
        }

        type ColumnClass = typeof Column;
        type ColumnProviderInterface = typeof ColumnProvider;
        type FileInfoInterface = typeof FileInfo;
        type InfoProviderInterface = typeof InfoProvider;
        type MenuClass = typeof Menu;
        type MenuItemClass = typeof MenuItem;
        type MenuProviderInterface = typeof MenuProvider;
        /**
         * Handle for asynchronous interfaces.
         *
         * These are opaque handles that must be unique within an extension object.
         * These are set by operations that return `NAUTILUS_OPERATION_IN_PROGRESS`.
         */
        abstract class OperationHandle {
            static $gtype: GObject.GType<OperationHandle>;

            // Constructors

            _init(...args: any[]): void;
        }

        type PropertiesItemClass = typeof PropertiesItem;
        type PropertiesModelClass = typeof PropertiesModel;
        type PropertiesModelProviderInterface = typeof PropertiesModelProvider;
        namespace ColumnProvider {
            /**
             * Interface for implementing ColumnProvider.
             * Contains only the virtual methods that need to be implemented.
             */
            interface Interface {
                // Virtual methods

                /**
                 * Provide a list of [class`Column]`.
                 *
                 * The `NautilusColumnProvider` only provides the metadata of the columns
                 * (importantly the [property`Column:`attribute]).  You will very likely also
                 * implement [iface`InfoProvider]` in order to call [method`FileInfo`.add_string_attribute]
                 * on all necessary files.
                 *
                 * This method should return immediately without any blocking i/o.
                 */
                vfunc_get_columns(): Column[] | null;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {}
        }

        export interface ColumnProviderNamespace {
            $gtype: GObject.GType<ColumnProvider>;
            prototype: ColumnProvider;
        }
        interface ColumnProvider extends GObject.Object, ColumnProvider.Interface {
            // Methods

            /**
             * Provide a list of [class`Column]`.
             *
             * The `NautilusColumnProvider` only provides the metadata of the columns
             * (importantly the [property`Column:`attribute]).  You will very likely also
             * implement [iface`InfoProvider]` in order to call [method`FileInfo`.add_string_attribute]
             * on all necessary files.
             *
             * This method should return immediately without any blocking i/o.
             * @returns the provided `NautilusColumn` objects
             */
            get_columns(): Column[] | null;
        }

        export const ColumnProvider: ColumnProviderNamespace & {
            new (): ColumnProvider; // This allows `obj instanceof ColumnProvider`
        };

        namespace FileInfo {
            /**
             * Interface for implementing FileInfo.
             * Contains only the virtual methods that need to be implemented.
             */
            interface Interface {
                // Virtual methods

                /**
                 * Add an emblem.
                 * @param emblem_name the name of an emblem
                 */
                vfunc_add_emblem(emblem_name: string): void;
                /**
                 * Set's the attributes value or replacing the existing value (if one exists).
                 *
                 * This function is necessary to set the value of the `NautilusFileInfo`'s
                 * correspond attribute for a [property`Column:`attribute].
                 * @param attribute_name the name of an attribute
                 * @param value the value of an attribute
                 */
                vfunc_add_string_attribute(attribute_name: string, value: string): void;
                /**
                 * Gets whether the `NautilusFileInfo` is writeable.
                 */
                vfunc_can_write(): boolean;
                /**
                 * Gets the activation uri.
                 *
                 * The activation uri may differ from the actual URI if e.g. the file is a .desktop
                 * file or a Nautilus XML link file.
                 */
                vfunc_get_activation_uri(): string;
                /**
                 * Get the cached [enum`Gio`.FileType].
                 */
                vfunc_get_file_type(): Gio.FileType;
                /**
                 * Get the corresponding [iface`Gio`.File]
                 */
                vfunc_get_location(): Gio.File;
                /**
                 * Get the cached mime_type.
                 */
                vfunc_get_mime_type(): string;
                /**
                 * Gets the cached mount.
                 *
                 * This only returns the [iface`Gio`.Mount] if Nautilus has already cached it.
                 * The return value may be `NULL` even if the `NautilusFileInfo` has a corresponding
                 * mount in which case you can call [method`Gio`.File.find_enclosing_mount_async].
                 */
                vfunc_get_mount(): Gio.Mount | null;
                /**
                 * Gets the name.
                 */
                vfunc_get_name(): string;
                /**
                 * Get the parent `NautilusFileInfo`.
                 *
                 * It's not safe to call this recursively multiple times, as it works
                 * only for files already cached by Nautilus.
                 */
                vfunc_get_parent_info(): FileInfo | null;
                /**
                 * Gets the parent location.
                 */
                vfunc_get_parent_location(): Gio.File | null;
                /**
                 * Get the parent `NautilusFileInfo` uri.
                 */
                vfunc_get_parent_uri(): string;
                /**
                 * Get the attribute's value.
                 * @param attribute_name the name of an attribute
                 */
                vfunc_get_string_attribute(attribute_name: string): string | null;
                /**
                 * Gets the URI.
                 */
                vfunc_get_uri(): string;
                /**
                 * Get the uri scheme.
                 */
                vfunc_get_uri_scheme(): string;
                /**
                 * Invalidate the current extension information.
                 *
                 * This removes any information, such as emblems or or string attributes, that
                 * were added to the `NautilusFileInfo` from any extension.
                 */
                vfunc_invalidate_extension_info(): void;
                /**
                 * Gets whether the `NautilusFileInfo` is a directory.
                 *
                 * Uses the cached [enum`Gio`.FileType] matches `G_FILE_TYPE_DIRECTORY` without
                 * doing any blocking i/o.
                 */
                vfunc_is_directory(): boolean;
                /**
                 * Get whether a `NautilusFileInfo` is gone.
                 */
                vfunc_is_gone(): boolean;
                /**
                 * Gets whether the mime_type of the `NautilusFileInfo` matches the given type.
                 * @param mime_type
                 */
                vfunc_is_mime_type(mime_type: string): boolean;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {}
        }

        export interface FileInfoNamespace {
            $gtype: GObject.GType<FileInfo>;
            prototype: FileInfo;

            /**
             * Get an existing `NautilusFileInfo` (if it exists) or create a new one is it
             * does not exist.
             * @param location the location to create the file info for
             */
            create(location: Gio.File): FileInfo;
            /**
             * Get an existing `NautilusFileInfo` (if it exists) or create a new one is it
             * does not exist.
             * @param uri the URI to lookup the file info for
             */
            create_for_uri(uri: string): FileInfo;
            /**
             * Deep copy a list of `NautilusFileInfo`.
             * @param files the files to copy
             */
            list_copy(files: FileInfo[]): FileInfo[];
            /**
             * Deep free a list of `NautilusFileInfo`.
             * @param files a list created with [func@FileInfo.list_copy]
             */
            list_free(files: FileInfo[]): void;
            /**
             * Get an existing `NautilusFileInfo` or `NULL` if it does not exist in the
             * application cache.
             * @param location the location for which to look up a corresponding #NautilusFileInfo object
             */
            lookup(location: Gio.File): FileInfo | null;
            /**
             * Get an existing `NautilusFileInfo` or `NULL` if it does not exist in the
             * application cache.
             * @param uri the URI to lookup the file info for
             */
            lookup_for_uri(uri: string): FileInfo | null;
        }
        interface FileInfo extends GObject.Object, FileInfo.Interface {
            // Methods

            /**
             * Add an emblem.
             * @param emblem_name the name of an emblem
             */
            add_emblem(emblem_name: string): void;
            /**
             * Set's the attributes value or replacing the existing value (if one exists).
             *
             * This function is necessary to set the value of the `NautilusFileInfo`'s
             * correspond attribute for a [property`Column:`attribute].
             * @param attribute_name the name of an attribute
             * @param value the value of an attribute
             */
            add_string_attribute(attribute_name: string, value: string): void;
            /**
             * Gets whether the `NautilusFileInfo` is writeable.
             * @returns %TRUE when @file_info is writeable, and %FALSE otherwise
             */
            can_write(): boolean;
            /**
             * Gets the activation uri.
             *
             * The activation uri may differ from the actual URI if e.g. the file is a .desktop
             * file or a Nautilus XML link file.
             * @returns the activation URI of @file_info
             */
            get_activation_uri(): string;
            /**
             * Get the cached [enum`Gio`.FileType].
             * @returns the file type
             */
            get_file_type(): Gio.FileType;
            /**
             * Get the corresponding [iface`Gio`.File]
             * @returns the corresponding location.
             */
            get_location(): Gio.File;
            /**
             * Get the cached mime_type.
             * @returns the MIME type of @file_info
             */
            get_mime_type(): string;
            /**
             * Gets the cached mount.
             *
             * This only returns the [iface`Gio`.Mount] if Nautilus has already cached it.
             * The return value may be `NULL` even if the `NautilusFileInfo` has a corresponding
             * mount in which case you can call [method`Gio`.File.find_enclosing_mount_async].
             * @returns the mount of @file_info,                                      or %NULL if @file_info has no mount
             */
            get_mount(): Gio.Mount | null;
            /**
             * Gets the name.
             * @returns the file name of @file_info
             */
            get_name(): string;
            /**
             * Get the parent `NautilusFileInfo`.
             *
             * It's not safe to call this recursively multiple times, as it works
             * only for files already cached by Nautilus.
             * @returns a #NautilusFileInfo for the parent of @file_info,                                      or %NULL if @file_info has no parent.
             */
            get_parent_info(): FileInfo | null;
            /**
             * Gets the parent location.
             * @returns a #GFile for the parent location of @file_info,   or %NULL if @file_info has no parent
             */
            get_parent_location(): Gio.File | null;
            /**
             * Get the parent `NautilusFileInfo` uri.
             * @returns the URI for the parent location of @file_info, or the empty string   if it has none
             */
            get_parent_uri(): string;
            /**
             * Get the attribute's value.
             * @param attribute_name the name of an attribute
             * @returns the value for the given @attribute_name, or %NULL if   there is none
             */
            get_string_attribute(attribute_name: string): string | null;
            /**
             * Gets the URI.
             * @returns the file URI of @file_info
             */
            get_uri(): string;
            /**
             * Get the uri scheme.
             * @returns the URI scheme of @file_info
             */
            get_uri_scheme(): string;
            /**
             * Invalidate the current extension information.
             *
             * This removes any information, such as emblems or or string attributes, that
             * were added to the `NautilusFileInfo` from any extension.
             */
            invalidate_extension_info(): void;
            /**
             * Gets whether the `NautilusFileInfo` is a directory.
             *
             * Uses the cached [enum`Gio`.FileType] matches `G_FILE_TYPE_DIRECTORY` without
             * doing any blocking i/o.
             * @returns %TRUE when @file_info is a directory, and %FALSE otherwise
             */
            is_directory(): boolean;
            /**
             * Get whether a `NautilusFileInfo` is gone.
             * @returns whether the file is gone.
             */
            is_gone(): boolean;
            /**
             * Gets whether the mime_type of the `NautilusFileInfo` matches the given type.
             * @param mime_type
             * @returns %TRUE when the MIME type of @file_info matches @mime_type, and   %FALSE otherwise
             */
            is_mime_type(mime_type: string): boolean;
        }

        export const FileInfo: FileInfoNamespace & {
            new (): FileInfo; // This allows `obj instanceof FileInfo`
        };

        namespace InfoProvider {
            /**
             * Interface for implementing InfoProvider.
             * Contains only the virtual methods that need to be implemented.
             */
            interface Interface {
                // Virtual methods

                /**
                 * Called when the Nautilus application has canceled an update.
                 *
                 * This method is only relevant if [method`InfoProvider`.update_file_info] was returned with
                 * `NAUTILUS_OPERATION_IN_PROGRESS`.
                 * @param handle the opaque #NautilusOperationHandle returned from a previous call to          nautilus_info_provider_update_file_info().
                 */
                vfunc_cancel_update(handle: OperationHandle): void;
                /**
                 * Called when the Nautilus application is requesting updated file information.
                 * @param file a file requesting updated info.
                 * @param update_complete the closure to invoke at some later time when returning                   @NAUTILUS_OPERATION_IN_PROGRESS.
                 */
                vfunc_update_file_info(
                    file: FileInfo,
                    update_complete: GObject.Closure,
                ): [OperationResult, OperationHandle | null];
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {}
        }

        export interface InfoProviderNamespace {
            $gtype: GObject.GType<InfoProvider>;
            prototype: InfoProvider;

            /**
             * Complete an async file info update.
             * @param update_complete the closure to call
             * @param provider an info provider
             * @param handle the handle for the given closure
             * @param result either `NAUTILUS_OPERATION_COMPLETE` or `NAUTILUS_OPERATION_FAILED`
             */
            update_complete_invoke(
                update_complete: GObject.Closure,
                provider: InfoProvider,
                handle: OperationHandle,
                result: OperationResult,
            ): void;
        }
        interface InfoProvider extends GObject.Object, InfoProvider.Interface {
            // Methods

            /**
             * Called when the Nautilus application has canceled an update.
             *
             * This method is only relevant if [method`InfoProvider`.update_file_info] was returned with
             * `NAUTILUS_OPERATION_IN_PROGRESS`.
             * @param handle the opaque #NautilusOperationHandle returned from a previous call to          nautilus_info_provider_update_file_info().
             */
            cancel_update(handle: OperationHandle): void;
            /**
             * Called when the Nautilus application is requesting updated file information.
             * @param file a file requesting updated info.
             * @param update_complete the closure to invoke at some later time when returning                   @NAUTILUS_OPERATION_IN_PROGRESS.
             * @returns whether the operation finished.
             */
            update_file_info(
                file: FileInfo,
                update_complete: GObject.Closure,
            ): [OperationResult, OperationHandle | null];
        }

        export const InfoProvider: InfoProviderNamespace & {
            new (): InfoProvider; // This allows `obj instanceof InfoProvider`
        };

        namespace MenuProvider {
            /**
             * Interface for implementing MenuProvider.
             * Contains only the virtual methods that need to be implemented.
             */
            interface Interface {
                // Virtual methods

                /**
                 * Called at least once whenever the current view changes.
                 * @param current_folder the folder for which background items are requested
                 */
                vfunc_get_background_items(current_folder: FileInfo): MenuItem[] | null;
                /**
                 * Called whenever the selected files in a view changes.
                 * @param files a list of selected files
                 */
                vfunc_get_file_items(files: FileInfo[]): MenuItem[] | null;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {}
        }

        export interface MenuProviderNamespace {
            $gtype: GObject.GType<MenuProvider>;
            prototype: MenuProvider;
        }
        interface MenuProvider extends GObject.Object, MenuProvider.Interface {
            // Methods

            /**
             * Emits [signal`MenuProvider:`:items-updated].
             */
            emit_items_updated_signal(): void;
            /**
             * Called at least once whenever the current view changes.
             * @param current_folder the folder for which background items are requested
             * @returns the provided list of items.
             */
            get_background_items(current_folder: FileInfo): MenuItem[] | null;
            /**
             * Called whenever the selected files in a view changes.
             * @param files a list of selected files
             * @returns the provided list of items.
             */
            get_file_items(files: FileInfo[]): MenuItem[] | null;
        }

        export const MenuProvider: MenuProviderNamespace & {
            new (): MenuProvider; // This allows `obj instanceof MenuProvider`
        };

        namespace PropertiesModelProvider {
            /**
             * Interface for implementing PropertiesModelProvider.
             * Contains only the virtual methods that need to be implemented.
             */
            interface Interface {
                // Virtual methods

                /**
                 * This function is called by the application when it wants properties models
                 * from the extension.
                 *
                 * This function is called in the main thread before the Properties are shown,
                 * so it should return quickly. The models can be populated and updated
                 * asynchronously.
                 * @param files a list of files
                 */
                vfunc_get_models(files: FileInfo[]): PropertiesModel[] | null;
            }

            // Constructor properties interface

            interface ConstructorProps extends GObject.Object.ConstructorProps {}
        }

        export interface PropertiesModelProviderNamespace {
            $gtype: GObject.GType<PropertiesModelProvider>;
            prototype: PropertiesModelProvider;
        }
        interface PropertiesModelProvider extends GObject.Object, PropertiesModelProvider.Interface {
            // Methods

            /**
             * This function is called by the application when it wants properties models
             * from the extension.
             *
             * This function is called in the main thread before the Properties are shown,
             * so it should return quickly. The models can be populated and updated
             * asynchronously.
             * @param files a list of files
             * @returns a list of models.
             */
            get_models(files: FileInfo[]): PropertiesModel[] | null;
        }

        export const PropertiesModelProvider: PropertiesModelProviderNamespace & {
            new (): PropertiesModelProvider; // This allows `obj instanceof PropertiesModelProvider`
        };

        /**
         * Name of the imported GIR library
         * `see` https://gitlab.gnome.org/GNOME/gjs/-/blob/master/gi/ns.cpp#L188
         */
        const __name__: string;
        /**
         * Version of the imported GIR library
         * `see` https://gitlab.gnome.org/GNOME/gjs/-/blob/master/gi/ns.cpp#L189
         */
        const __version__: string;
    }

    export default Nautilus;
}

declare module 'gi://Nautilus' {
    import Nautilus41 from 'gi://Nautilus?version=4.1';
    export default Nautilus41;
}
// END
