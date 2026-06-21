"use client";

import { useCallback, useEffect, useState } from "react";
import { runActionWithToast } from "@/core/lib/runActionWithToast";
import {
  downloadReportFile,
  exportAdminReport,
  getReportOverview,
} from "../services/reports.service";
import type {
  ReportExportFormat,
  ReportExportType,
  ReportFilters,
  ReportOverview,
} from "../types";
import type { ReportTab } from "../types/workspace";

function defaultFilters(): Required<ReportFilters> {
  const from = new Date();
  from.setDate(from.getDate() - 89);
  return {
    fromDate: from.toISOString().slice(0, 10),
    toDate: new Date().toISOString().slice(0, 10),
    groupBy: "day",
  };
}

export function useReportsWorkspace() {
  const initialFilters = defaultFilters();
  const [activeTab, setActiveTab] = useState<ReportTab>("overview");
  const [draftFilters, setDraftFilters] = useState<ReportFilters>(initialFilters);
  const [filters, setFilters] = useState<ReportFilters>(initialFilters);
  const [overview, setOverview] = useState<ReportOverview | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isExporting, setIsExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadOverview = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      setOverview(await getReportOverview(filters));
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : "Không thể tải báo cáo.");
    } finally {
      setIsLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    void loadOverview();
  }, [loadOverview]);

  const applyFilters = () => {
    setFilters({ ...draftFilters });
  };

  const exportReport = async (
    format: ReportExportFormat,
    reportType: ReportExportType = "all",
  ) => {
    setIsExporting(true);
    try {
      const result = await runActionWithToast(
        () => exportAdminReport(filters, reportType, format),
        { loading: "Đang chuẩn bị báo cáo...", success: "Đã tải file báo cáo." },
      );
      downloadReportFile(result);
    } finally {
      setIsExporting(false);
    }
  };

  return {
    activeTab,
    setActiveTab,
    draftFilters,
    setDraftFilters,
    filters,
    applyFilters,
    overview,
    isLoading,
    isExporting,
    error,
    refresh: loadOverview,
    exportReport,
  };
}
