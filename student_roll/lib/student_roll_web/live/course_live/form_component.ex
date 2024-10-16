defmodule StudentRollWeb.CourseLive.FormComponent do
  use StudentRollWeb, :live_component

  alias StudentRoll.Enrollment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage course records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="course-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:max_students]} type="number" label="Max students" />
        <.input field={@form[:waitlist_size]} type="number" label="Waitlist size" />
        <.input field={@form[:min_age]} type="number" label="Min age" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Course</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{course: course} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Enrollment.change_course(course))
     end)}
  end

  @impl true
  def handle_event("validate", %{"course" => course_params}, socket) do
    changeset = Enrollment.change_course(socket.assigns.course, course_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"course" => course_params}, socket) do
    save_course(socket, socket.assigns.action, course_params)
  end

  defp save_course(socket, :edit, course_params) do
    case Enrollment.update_course(socket.assigns.course, course_params) do
      {:ok, course} ->
        notify_parent({:saved, course})

        {:noreply,
         socket
         |> put_flash(:info, "Course updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_course(socket, :new, course_params) do
    case Enrollment.create_course(course_params) do
      {:ok, course} ->
        notify_parent({:saved, course})

        {:noreply,
         socket
         |> put_flash(:info, "Course created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
