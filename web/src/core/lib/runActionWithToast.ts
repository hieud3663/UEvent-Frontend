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

  return 'Đã xảy ra lỗi. Vui lòng thử lại.';
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
    toast.error(getErrorMessage(error) || options.error || 'Đã xảy ra lỗi. Vui lòng thử lại.', { id: toastId });
    throw error;
  }
}
