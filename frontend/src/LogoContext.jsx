import { createContext, useEffect, useState } from "react";
import System from "./models/system";

export const REFETCH_LOGO_EVENT = "refetch-logo";
export const LogoContext = createContext();
const CUSTOM_LOGO_URL = "/imagen.png";

export function LogoProvider({ children }) {
  const [logo, setLogo] = useState("");
  const [loginLogo, setLoginLogo] = useState("");
  const [isCustomLogo, setIsCustomLogo] = useState(false);
  const DefaultLoginLogo = CUSTOM_LOGO_URL;

  async function fetchInstanceLogo() {
    // Always use the custom logo path, ignore server-stored logos
    setLogo(CUSTOM_LOGO_URL);
    setLoginLogo(CUSTOM_LOGO_URL);
    setIsCustomLogo(false);
  }

  useEffect(() => {
    fetchInstanceLogo();
    window.addEventListener(REFETCH_LOGO_EVENT, fetchInstanceLogo);
    return () => {
      window.removeEventListener(REFETCH_LOGO_EVENT, fetchInstanceLogo);
    };
  }, []);

  return (
    <LogoContext.Provider value={{ logo, setLogo, loginLogo, isCustomLogo }}>
      {children}
    </LogoContext.Provider>
  );
}
