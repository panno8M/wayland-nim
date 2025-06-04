struct wl_resource {
	struct wl_object obj;
	wl_resource_destroy_func_t destroy;
	struct wl_list link;
	struct wl_signal destroy_signal;
	struct wl_client *client;
	void *data;
};