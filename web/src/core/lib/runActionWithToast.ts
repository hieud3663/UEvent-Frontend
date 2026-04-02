import { toast } from 'sonner';

interface ActionToastOptions {
  loading: string;
  success: string;
  error?: string;
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error && error.message) {
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}

export async function runActionWithToast<T>(
  action: () => Promise<T>,
  options: ActionToastOptions
): Promise<T> {
  const toastId = toast.loading(options.loading);

  try {
    const result = await action();
    toast.success(options.success, { id: toastId });
    return result;
  } catch (error) {
    toast.error(options.error ?? getErrorMessage(error), { id: toastId });
    throw error;
  }
}
