import paths from "@/utils/paths";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

export default function OnboardingHome() {
  const navigate = useNavigate();
  const { t } = useTranslation();

  return (
    <>
      <div className="relative w-screen h-screen flex overflow-hidden bg-theme-bg-primary">
        <div className="relative flex justify-center items-center m-auto">
          <div className="flex flex-col justify-center items-center">
            <p className="text-theme-text-primary font-thin text-[24px] mb-4">
              {t("onboarding.home.title")}
            </p>
            <img
              src="/imagen.png"
              alt="Agent AI"
              className="h-[80px] md:h-[100px] flex-shrink-0 max-w-[400px] object-contain"
            />
            <button
              onClick={() => navigate(paths.onboarding.llmPreference())}
              className="border-[2px] border-theme-text-primary animate-pulse light:animate-none w-full md:max-w-[350px] md:min-w-[300px] text-center py-3 bg-theme-button-primary hover:bg-theme-bg-secondary text-theme-text-primary font-semibold text-sm my-10 rounded-md "
            >
              {t("onboarding.home.getStarted")}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
